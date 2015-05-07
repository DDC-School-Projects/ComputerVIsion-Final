%%! Clusters Data using the Kmeans algorithm.
%%!
%%! Octave Implementation Used as a reference.  
%%! This Implementation 
%%!    - uses more vectorized code which runs about 3x faster,
%%!    - Offers more initialization methods
%%!    - Offers more options when an empty cluster is encountered
%%!    - Offers Visualization of Convergence
%%!    - Offers a limit for number of iterations to perform before giving up
%%!
%%! @param data   the NxM data matrix where N is the number of samples
%%!                                         M is the dimension of each sample
%%! @param k      the number of clusters to use
%%!
%%! @prop init_method  The method to use for k-means initialization.
%%!       ['random']     - randomly place samples in clusters
%%!       ['even_space'] - linearly space from nearest to furthest from origin
%%!       ['all_in_one'] - place all samples in cluster 1
%%!       ['n_over_k']   - place same number of samples in each cluster
%%! @prop empty_action The action to perform when an empty cluster is found.
%%!       ['random']           - randomly choose
%%!       ['random_large']     - randomly choose from largest cluster
%%!       ['furthest']         - choose sample furthest from its center
%%!       ['furthest_large']  - choose furthest sample from largest cluster
%%! @prop max_err      The maximum error in the result
%%! @prop max_iters    The Maximum Iterations to perform before returning
%%!
%%! @return s          The Nx1 vector of sample classes
%%! @return mu         The KxM center of each cluster 
%%! @return sumd       The sum of distances
function [s, mu,sumd] = kmeans_ddc(data,k, varargin)
  %args = {init_method , empty_action, max_err, max_iters}  
  args = _parse_kmeans_varargs(varargin);
  init_method  = args{1};
  empty_action = args{2};
  maxerr       = args{3};
  max_iters    = args{4};
  visualize    = args{5};
  
  data = make_signed(data);
  [n,d] = size(data);
  
  [s,mu] = _initialize_kmeans(data,k,init_method);

  err = inf;
  prev_sumd=inf;
  iters = 0;
  while err>=maxerr && iters < max_iters
    if visualize   % Draw a scatter of each classes center each iteration
      figure(100);
      gscatter(mu,1:k,mu./255);
      title(sprintf('Iteration: %d    Err: %4.5f',iters,err));
      hold off;
      drawnow;
    end
    iters = iters+1;
   
    %Get the Squared Distance of each sample to each cluster center
    %D(i,j) = square distance from sample_i to mean_j;
    for i = 1:k
      D(:,i) = sumsq(data(:,:) - repmat(mu(i,:),n,1),2);
    end
    [min_d, s] = min(D,[],2);        %update the clusters
    

    for r=1:k                        %Update the means
      if isempty(find(s==r))  
        %Converged to a local minima of 0, fix by
        i            = _chooseSampleIdx(data,mu,s,empty_action); %choose sample      
        clust        = s(i);                            %Store the old cluster
        s(i)         = r;                               %Move to this cluster
        mu(r,:)      = data(i);                         %Update this clusters mu              
        mu(clust,:)  = mean(data(find(s==clust),:));    %Update old clusters mu
      else
        mu(r,:)      = mean(data(find(s==r),:));
      end
      
    end
    
    %calculate the difference in the sum of distances
    sumd = sum(sumsq(data-mu(s,:),2));
    err  = prev_sumd - sumd;
    prev_sumd = sumd;
  endwhile
  
  if err>=maxerr
    s    = zeros(n,1);
    mu   = zeros(k,d);
    sumd = 0;
    warning('Warning KMeans did not Converge within Specified Iterations');
  end
  
end



%%! Helper function to parse the varargs
function args = _parse_kmeans_varargs(varargin)
    [reg, prop] = parseparams (varargin{1,1});
    %args = {init_method , empty_action, max_err, max_iters}
    args{1} = getVarArg('init_method'  , 'even_space'      ,prop);
    args{2} = getVarArg('empty_action' , 'furthest_large' ,prop);
    args{3} = getVarArg('max_err'      , .001              ,prop);
    args{4} = getVarArg('max_iters'    , inf               ,prop);
    args{5} = getVarArg('visualize'    , false             ,prop);
end

%%! HElper function to initialize the Kmeans clusters
function [s,mu] = _initialize_kmeans(data,k,init_method)
  [n,dim]=size(data);
  switch(init_method)
    case 'all_in_one'                           %Start with all in Group 1
      s  = ones(n,1);
      mu = zeros(k,dim);
      mu(1,:) = mean(data);
      
    case 'random'                               %Start with random groupings
      s = round(unifrnd(.5,k+.4,[n,1]));
      for i=1:k
        mu(i,:) = mean(data(find(s==i),:));
      end
      
    case 'n_over_k'                             %Start with N/K samples in each
      num_each = floor(n/k);
      s = zeros(n,1);
      for i = 1:k
        s((i-1)*k:end) = i;
      end
      for i=1:k
        mu(i,:) = mean(data(find(s==i),:));
      end
      
    case 'even_space'                           %Groupings Based on Min and Max
      d = sumsq(data,2);
      [v_min,i_min] = min(d);
      [v_max,i_max] = max(d);
      min_val = data(i_min,:);
      max_val = data(i_max,:);
      s=zeros(n,1);
      mu = linspace(min_val,max_val,k+2)'(2:end-1,:); 
   
    otherwise
      error('Error: Unknown Initialization Method');
      
   end
end

%% Function which chooses the index of the sample to move to the empty cluster
function idx = _chooseSampleIdx(data,mu,s,empty_action)
  k=rows(mu);
  n=rows(data);
  
  switch (empty_action)
    case 'random'			          %choose a random sample
        idx = round(unifrnd(.5,n+.4));

    case 'furthest'			          %choose furthest from cluster
        sizes = zeros(1,k);
        for i=1:k
          sizes(i) = sum(s==i);
        end
        %Max size and cluster index
        [ms,ci]  = max(sizes);  
        dists    = sumsq(data-mu(s,:),2);
        [md,idx] = max(dists);

    case 'furthest_large'	         %Choose furthest pt in largest cluster
        sizes = zeros(1,k);              
        for i=1:k
          sizes(i) = sum(s==i);
        end
        [ms,ci] = max(sizes);
        indices = find(s==ci);
        g = data(indices,:);
        dists = sumsq(g-repmat(mu(ci,:),ms,1),2);
        [md,i] = max(dists);   
        idx = indices(i);      

    case 'random_large'			 %Choose a random pt in largest cluster 
      sizes   = sum(s==1:k);            
      [ms,ci] = max(sizes);
      indices = find(s==ci);
      idx = indices(round(unifrnd(.5,rows(indices)+.4)))
      
    otherwise
       error('Error: Unknown Empty CLuster Action'); 
  end
end


