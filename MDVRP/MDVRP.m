data = fopen('p01','r');%Open data file.
Problem = fscanf(data,'%i %i %i %i',[1 4]);%Read first line with the problem type etc.(Type,Vehicles Number,Customers Number,Depots Number)
Vehicles = fscanf(data,'%i %i',[2 Problem(2)]).';%Read the Vehicles Specs(Max Duration,Max Load)
Customers = fscanf(data,'%i %i %i %i %i %i %i %i %i %i %i',[11 Problem(3)]).';%Read the main data (Customer Id,x coordinate,y coordinate ,.,demand, .,.,.,.)
Depots = fscanf(data,'%i %i %i %i   %i %i %i',[7 Problem(4)]).';%Read the Depot Coordinates.(Depots ID,x coordinate,y coordinate,.,.,.)
fclose('all');
Nodes =  Customers;
Nodes  = Nodes(:,1:7);
Nodes = [Nodes;Depots];
%Calculates the distance of every customer from every depot.
for i = 1:4
    for j = 1:54
        depots_dist(i,j) = sqrt((Nodes(Problem(3)+i,2)-Nodes(j,2))^2 + (Nodes(Problem(3)+i,3)-Nodes(j,3))^2);
    end
end
%Find in which Cluster every customer is assigned to .
[Min Min_Index] = min(depots_dist);%Find min from every collumn(depot_dist) and saves index(thesi dld)
%Find size of each cluster
Cluster_size = zeros(size(Problem(4)));
for i = 1:Problem(4)
    Cluster_size(i) = sum(Min_Index==i);
end
%End(Cluster Size)
%Assign every customer to a cluster 
for i=1:Problem(4)
  Cluster{i} = zeros(1,Cluster_size(i));
  Counter(i) = 1;
end
problem_size = Problem(3)+Problem(4);
for i=1:Problem(4)
    for j =1:problem_size 
        if(Min_Index(j)==i)
            Cluster{i}(Counter(i)) = j;
            Counter(i)=Counter(i) + 1;
        end
    end
end
%End(Clustering)
%Cost matrix calculation
cost = zeros(problem_size,problem_size);
for i=1:problem_size 
        for j=1:problem_size 
                cost(i,j) = sqrt((Nodes(i,2)-Nodes(j,2))^2  + (Nodes(i,3)-Nodes(j,3))^2);
        end
end
%Nearest Neighbor
%Cell array containing the solution for each cluster 
route = cell(1,Problem(4));
%Copy of the cost matrix
cost_temp = cost;
%Put infinity in the main diagonal 
for i=1:54
    for j=1:54
        if(i==j)
            cost_temp(i,j) = inf;
        end    
    end
end
%For each cluster 
for i=1:Problem(4)
      %Q is the capacity of the current vehicle
      Q = Vehicles(1,2);
      %Pick a random customer from the current cluster 
      random = Cluster{i}(1:end-1);
      msize = numel(random);
      idx = randperm(msize);
      random_el = random(idx(1:1));
      %Put zeros on the current cluster route 
      route{i} = zeros(1,2*Cluster_size(i));
      %Start from the depot
      route{i}(1) = Cluster{i}(end); 
      %Visit the first random customer we previously chose 
      route{i}(2) = random_el; 
      %Decrease the capacity of the vehicle 
      Q=Q-Nodes(random_el,5);
      %Count_cluster is the number of the served customers in the current
      %cluster 
      count_cluster =1;
      %Count_route is the position in the route array .
      count_route = 3; 
      %s_customers shows the served customers 
      %Put zeros in s_customers 
      s_customers = zeros(1,Cluster_size(i));
      %Put in first position of s_customers the first random customer 
      s_customers(1) = random_el;
      %Initialize min_cost and min_index
      min_cost = inf;
      min_index =0;
      %While unserved customers exist do ...
      while count_cluster<Cluster_size(i)-2
          min_cost = inf;
          min_index=0;
          %For each customer in the cluster except the depot do ...
          for k=1:Cluster_size(i)-1
              %if the distance of the previous to the current customer is
              %less than the minimum and the current customer is not served
              %do ...
              if(cost(route{i}(count_route-1),Cluster{i}(k))<= min_cost) &  sum(Cluster{i}(k)==s_customers)==0
                  %Update the minimum and and minimum 's index
                  min_cost = cost(route{i}(count_route-1),Cluster{i}(k));
                  min_index = Cluster{i}(k);
              end
          end
          
        
            %if the current customer demand is less than the current
            %capacity do ...
            if Nodes(min_index,5) <=  Q
                %Put the current customer in the route
                route{i}(count_route) = min_index;
                %Decrease the capacity
                Q = Q - Nodes(min_index,5);
                %Update the number of served customers  
                count_cluster = count_cluster + 1;
                %Set current customer as served
                s_customers(count_cluster) = min_index;
            %if the customer cannot be served return to depot
            else
                %Reload the vehicle
                Q = Vehicles(1,2);
                %Return to depot
                route{i}(count_route) = Cluster{i}(end);
            end
            %Go to the next customer 
            count_route = count_route + 1;
      end
      route{i}(count_route) = Cluster{i}(end); 
      route{i}(route{i}==0) = [];
end
%Calculate routes cost
route_cost = zeros(1,4);
for i=1:4
    for j=1:(length(route{i})-1)
        route_cost(i) = route_cost(i) + cost(route{i}(j),route{i}(j+1));
    end
end
%Calculate total cost 
cost_total = 0;
for i=1:4
    cost_total = cost_total + route_cost(i);
end
%Cell array containing all the routes for all the depots
routes_all = cell(1,20);
%Pointer that shows the position in the routes_all cell aray
routes_pos = 0;
%Cell array that contains vectors tha show the positions of the depot
%inside the whole route for a specific depot vehicle
depot_pos = cell(1,4);
%For every depot do ...
for i=1:4
    %Find the positions of the depot inside the whole route of the current depot vehicle 
    depot_pos{i} = find(route{i}==50+i);
    %For each individual route of a specific depot vehicle do ...
    for j=1:length(depot_pos{i})-1
        %Update position in the cell array containing the routes
        routes_pos = routes_pos + 1;
        %Set the current route that is contained in the whole route
        routes_all{routes_pos} = route{i}(depot_pos{i}(j):depot_pos{i}(j+1));    
    end
end
%Delete empty elements from the cell array containing the all the routes
routes_all = routes_all(~cellfun(@isempty, routes_all));
%Make a copy of the cell array containing all the routes
routes_all_temp = routes_all;
routes_final = routes_all;
%Initialize vector that contains the optimized cost of each route
new_cost = zeros(1,length(routes_all));
%Initialize variable to compute the old route's cost
old_cost = zeros(1,length(routes_all));
%For every individual route do ...
for i=1:routes_pos
    %if the length of the current route is greater than 6(if 3-opt
    %algorithm can be applied)
    if length(routes_all{i})>=6
        %Initialize vector containing the random cuts for the 3-opt algorithm
        random_cuts = zeros(1,3);
        random_pos = 0;
        %Generate the random cuts
        random = randperm(length(routes_all{i}));
        random_el2 = random(1:3);
        %Sort the random cuts in ascending order 
        random_el3 = sort(random_el2);
        %While the is a depot in the random cuts do ...
        while sum(routes_all{i}(random_el2) == routes_all{i}(1)) ~= 0
            %Generate new random cuts
            random = randperm(length(routes_all{i}));
            random_el2 = random(1:3);
            %Sort the new random cuts
            random_el3 = sort(random_el2);
        end
        %Make the permutations needed(I choose the right element of every
        %random generated number to form a cut)
        routes_all_temp{i}(1:random_el3(1)) = routes_all{i}(1:random_el3(1));
        routes_all_temp{i}(random_el3(1)+1:random_el3(2)) = fliplr(routes_all{i}(random_el3(1)+1:random_el3(2)));
        routes_all_temp{i}(random_el3(2)+1:random_el3(3)) = fliplr(routes_all{i}(random_el3(2)+1:random_el3(3)));
        routes_all_temp{i}(random_el3(3)+1:end) = routes_all{i}(random_el3(3)+1:end);
    end
    %for every node in the route(except the last one) do ...
    for j=1:length(routes_all{i})-1
        %Calculate old route's cost
        old_cost(i) = old_cost(i) + cost(routes_all{i}(j),routes_all{i}(j+1));
        %Calculate new route's cost
        new_cost(i) = new_cost(i) + cost(routes_all_temp{i}(j),routes_all_temp{i}(j+1));
    end
    
    
    %if the new route's cost is lesser than the old route's cost do ...
    if new_cost(i) < old_cost(i)
        %Set the final route as the new optimized route
        routes_final{i} = routes_all_temp{i};
    else
        new_cost(i) = old_cost(i);
    end
end





%Vector containing the cost of the whole route for every depot 
route_cost_new = zeros(1,4);
%Variable containing the cost of the whole problem 
cost_total_new = 0;
route_cost_old = zeros(1,4);
cost_total_old = 0;
%For every depot do ...
pos=0;
for i=1:4
    %Calculate the cost of every individual route, in a whole route of the
    %current depot(optimized) 
    for j=1:length(depot_pos{i})-1
        route_cost_new(i) = route_cost_new(i) +new_cost(pos+j);
        route_cost_old(i) = route_cost_old(i) +old_cost(pos+j);
    end
    pos=pos+j;
    %Calculate the cost of the whole route of the current depot
    cost_total_new = cost_total_new + route_cost_new(i);
    cost_total_old = cost_total_old + route_cost_old(i);
end
