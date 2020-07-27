# MDVRP

This is an attempt to solve the **Multi Depot Vehicle Routing Problem** using the **Nearest Neighbour Algorithm** for the base solution and the **3-opt algorithm** for the optimization of the base solution.


## Description

A company may have several depots from which it can serve its customers. If the customers are clustered around depots, then the distribution problem should be modeled as a set of independent VRPs. However, if the customers and the depots are intermingled then a Multi-Depot Vehicle Routing Problem should be solved.

A MDVRP requires the assignment of customers to depots. A fleet of vehicles is based at each depot. Each vehicle originate from one depot, service the customers assigned to that depot, and return to the same depot.

The objective of the problem is to service all customers while minimizing the number of vehicles and travel distance.

We can find below a formal description for the MDVRP:

**Objective:** The objective is to minimize the vehicle fleet and the sum of travel time, and the total demand of commodities must be served from several depots.  

**Feasibility:** A solution is feasible if each route satisfies the standard VRP constraints and begins and ends at the same depot.    
  
**Formulation:** The VRP problem is extended to the case wherein we have multiple depots, so we will note the vertex set like ${V = \left\lbrace v_{1}, …, v_{n} \right\rbrace \bigcup V_{0}}$, where ${V_{0} = \left\lbrace v_{01}, …, v_{0d} \right\rbrace}$ are the vertex representing the depots. Now, a route ${i}$ is defined by ${R_{i} = \left\lbrace d, v_{1}, …, v_{m}, d \right\rbrace}$, with ${d \in V_{0}}$. The cost of a route is calculated like in the case of the standard VRP.

**Reference:** http://www.bernabe.dorronsoro.es/
