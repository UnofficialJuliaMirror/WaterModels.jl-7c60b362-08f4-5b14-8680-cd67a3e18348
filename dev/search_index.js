var documenterSearchIndex = {"docs":
[{"location":"index.html#WaterModels.jl-Documentation-1","page":"Home","title":"WaterModels.jl Documentation","text":"","category":"section"},{"location":"index.html#","page":"Home","title":"Home","text":"CurrentModule = WaterModels","category":"page"},{"location":"index.html#Overview-1","page":"Home","title":"Overview","text":"","category":"section"},{"location":"index.html#","page":"Home","title":"Home","text":"WaterModels.jl is a Julia package for steady state water network optimization. It is designed to enable computational evaluation of historical and emerging water network formulations and algorithms using a common platform. The software is engineered to decouple problem specifications (e.g., feasibility, network expansion) from water network optimization formulations (e.g., mixed-integer linear, mixed-integer nonlinear). This decoupling enables the definition of a wide variety of water network optimization formulations and their comparison on common problem specifications.","category":"page"},{"location":"index.html#Installation-1","page":"Home","title":"Installation","text":"","category":"section"},{"location":"index.html#","page":"Home","title":"Home","text":"The latest stable release of WaterModels can be installed using the Julia package manager using","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"using Pkg\nPkg.add(\"WaterModels\")","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"For the current development version, \"check out\" this package using","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"using Pkg\nPkg.checkout(\"WaterModels\")","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"Finally, you can test that the package works by running","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"using Pkg\nPkg.test(\"WaterModels\")","category":"page"},{"location":"quickguide.html#Quick-Start-Guide-1","page":"Getting Started","title":"Quick Start Guide","text":"","category":"section"},{"location":"network-data.html#WaterModels-Network-Data-Format-1","page":"Network Data Format","title":"WaterModels Network Data Format","text":"","category":"section"},{"location":"result-data.html#WaterModels-Result-Data-Format-1","page":"Result Data Format","title":"WaterModels Result Data Format","text":"","category":"section"},{"location":"math-model.html#Mathematical-Models-in-WaterModels-1","page":"Mathematical Models","title":"Mathematical Models in WaterModels","text":"","category":"section"},{"location":"math-model.html#Notation-for-Sets-1","page":"Mathematical Models","title":"Notation for Sets","text":"","category":"section"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"A water distribution network can be represented by a directed graph mathcalG = (mathcalN mathcalA), where mathcalN is the set of nodes (e.g., junctions and reservoirs) and mathcalA is the set of arcs (e.g., pipes and valves). Herein, the set of pipes in the network is denoted as mathcalP subset mathcalA, the set of reservoirs (or sources) as mathcalS subset mathcalN, and the set of junctions as mathcalJ subset mathcalN. The set of arcs incident on node i in mathcalN, where i is the tail of the arc, is denoted as mathcalA^-(i) = (i j) in mathcalA. The set of arcs incident on node i in mathcalN, where i is the head of the arc, is denoted as mathcalA^+(i) = (j i) in mathcalA. Reservoirs are always considered to be supply (or source) nodes, and junctions are typically considered to be demand nodes (i.e., the demand for flow at the node is positive). For convenience, it is thus implied that mathcalS cap mathcalJ = emptyset. Finally, many network design problems are concerned with selecting from among a set of discrete resistances mathcalR(i j) = r_1 r_2 dots r_n^mathcalR_ij for a given pipe (i j) in mathcalP.","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"In summary, the following sets are commonly used when defining a WaterModels problem formulation:","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"Notation WaterModels Translation Description\nmathcalN wm.ref[:nw][n][:nodes] nodes\nmathcalJ subset mathcalN wm.ref[:nw][n][:junctions] junctions\nmathcalS subset mathcalN wm.ref[:nw][n][:reservoirs] reservoirs\nmathcalA wm.ref[:nw][n][:arcs] arcs\nmathcalP subset mathcalA wm.ref[:nw][n][:pipes] pipes\nmathcalA^-(i) subset mathcalA wm.ref[:nw][n][:arcs_to][i] arcs \"to\" node i\nmathcalA^+(i) subset mathcalA wm.ref[:nw][n][:arcs_from][i] arcs \"from\" node i\nmathcalR(i j) wm.ref[:nw][n][:resistances][ij] resistances for (i j) in mathcalP","category":"page"},{"location":"math-model.html#Physical-Feasibility-1","page":"Mathematical Models","title":"Physical Feasibility","text":"","category":"section"},{"location":"math-model.html#Satisfaction-of-Flow-Bounds-1","page":"Mathematical Models","title":"Satisfaction of Flow Bounds","text":"","category":"section"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"For each arc (i j) in mathcalA, a variable q_ij is used to represent the volumetric flow of water across the arc (in textrmm^3textrms). When q_ij is positive, flow on arc (i j) travels from node i to node j. When q_ij is negative, flow travels from node j to node i. The absolute value of flow along the arc can be bounded by physical capacity, engineering judgment, or network analysis. Having tight bounds is crucial for optimization applications. For example, maximum flow speed and the diameter of the pipe can be used to bound q_ij as per","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"    -fracpi4 v_ij^max D_ij^2 leq q_ij leq fracpi4 v_ij^max D_ij^2","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"where D_ij is the diameter of pipe (i j) and v^max_ij is the maximum flow speed along the pipe.","category":"page"},{"location":"math-model.html#Satisfaction-of-Head-Bounds-1","page":"Mathematical Models","title":"Satisfaction of Head Bounds","text":"","category":"section"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"Each node potential is denoted as h_i, i in mathcalN, and represents the hydraulic head in units of length (textrmm). The hydraulic head assimilates the elevation and pressure heads at each node, while the velocity head can typically be neglected. For each reservoir i in mathcalS, the hydraulic head is assumed to be fixed at a value h_i^textrmsrc, i.e.,","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"    h_i = h_i^textrmsrc  forall i in mathcalS","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"For each junction i in mathcalJ, a minimum hydraulic head underlineh_i, determined a priori, must first be satisfied. In the interest of tightening the optimization formulation, upper bounds on hydraulic heads can also typically be implied from other network data, e.g.,","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"    underlineh_i leq h_i leq overlineh_i = max_i in mathcalSh_i^textrmsrc","category":"page"},{"location":"math-model.html#Conservation-of-Flow-at-Non-supply-Nodes-1","page":"Mathematical Models","title":"Conservation of Flow at Non-supply Nodes","text":"","category":"section"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"Flow must be delivered throughout the network to satisfy fixed demand, q_i^textrmdem, at non-supply nodes, i.e.,","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\tsum_(j i) in mathcalA^-(i) q_ji - sum_(i j) in mathcalA^+(i) q_ij = q_i^textrmdem  forall i in mathcalJ","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"where mathcalA^-(i) and mathcalA^+(i) are the sets of incoming and outgoing arcs of node i, respectively.","category":"page"},{"location":"math-model.html#Conservation-of-Flow-at-Supply-Nodes-1","page":"Mathematical Models","title":"Conservation of Flow at Supply Nodes","text":"","category":"section"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"The outflow from each reservoir will be nonnegative by definition, i.e.,","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\tsum_(i j) in mathcalA^+(i) q_ij - sum_(j i) in mathcalA^-(i) q_ji geq 0  forall i in mathcalS","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"Additionally, an upper bound on the amount of flow delivered by a reservoir may be written","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\t sum_(i j) in mathcalA^+(i) q_ij - sum_(j i) in mathcalA^-(i) q_ji leq sum_k in mathcalJ q^textrmdem_k  forall i in mathcalR","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"i.e., a reservoir will never send more flow than the amount required to serve all demand.","category":"page"},{"location":"math-model.html#Head-Loss-Relationships-1","page":"Mathematical Models","title":"Head Loss Relationships","text":"","category":"section"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"In water distribution networks, flow along an arc is induced by the difference in potential (head) between the two nodes that connect that arc. The relationships that link flow and hydraulic head are commonly referred to as the \"head loss equations\" or \"potential-flow constraints,\" and are generally of the form","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\th_i - h_j = Phi_ij(q_ij)","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"where Phi_ij  mathbbR to mathbbR is a strictly increasing function with rotational symmetry about the origin. Embedding the above equation in a mathematical program clearly introduces non-convexity. (That is, the function Phi_ij(q_ij) is non-convex and the relationship must be satisfied with equality.) As such, different formulations primarily aim to effectively deal with these types of non-convex constraints in an optimization setting.","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"Explicit forms of the head loss equation include the Darcy-Weisbach equation, i.e.,","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\th_i - h_j = frac8 L_ij lambda_ij q_ij lvert q_ij rvertpi^2 g D_ij^5","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"and the Hazen-Williams equation, i.e.,","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\th_i - h_j = frac1067 L_ij q_ij lvert q_ij rvert^0852kappa_ij^1852 D_ij^487","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"In these equations, L_ij represents the length of pipe (i j) in mathcalA, lambda_ij represents the friction factor, g is the acceleration due to gravity, and kappa_ij is the roughness coefficient, which depends on the material of the pipe. In the Darcy-Weisbach formulation, lambda_ij depends on the Reynolds number (and thus the flow q_ij) in a nonlinear manner. In WaterModels.jl, the Swamee-Jain equation is used, which serves as an explicit approximation of the implicit Colebrook-White equation. The equation computes the friction factor lambda_ij for (i j) in mathcalA as","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\tlambda_ij = frac025leftlog left(fracepsilon_ij  D_ij37 + frac574textrmRe_ij^09right)right^2","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"where epsilon_ij is the pipe's effective roughness and the Reynold's number textrmRe_ij is defined as","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\ttextrmRe_ij = fracD_ij v_ij rhomu","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"where v_ij is the mean flow speed, rho is the density, and mu is the viscosity. Herein, to remove the source of nonlinearity in the Swamee-Jain equation, v_ij is estimated a priori, making the overall resistance term fixed.","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"When all variables in a head loss equation except q_ij are fixed (as in the relations described above), both the Darcy-Weisbach and Hazen-Williams formulations for head loss reduce to a convenient form, namely","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\th_i - h_j = L_ij r_ij q_ij lvert q_ij rvert^alpha","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"Here, r_ij represents the resistance per unit length, and alpha is the exponent required by the head loss relationship (i.e., one for Darcy-Weisbach and 0852 for Hazen-Williams). Thus, the Darcy-Weisbach resistance per unit length is","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\tr_ij = frac8 lambda_ijpi^2 g D_ij^5","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"and the Hazen-Williams resistance per unit length is","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"\tr_ij = frac1067kappa_ij^1852 D_ij^487","category":"page"},{"location":"math-model.html#Non-convex-Nonlinear-Program-1","page":"Mathematical Models","title":"Non-convex Nonlinear Program","text":"","category":"section"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"The full non-convex formulation of the physical feasibility problem (NCNLP), which incorporates all requirements from Physical Feasibility, may be written as a system that satisfies the following constraints:","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"beginalign\n    h_i - h_j = L_ij r_ij q_ij lvert q_ij rvert^alpha  forall (i j) in mathcalA labeleqnncnlp-head-loss \n    h_i = h_i^textrmsrc  forall i in mathcalS labeleqnncnlp-head-source \n    sum_(j i) in mathcalA^-(i) q_ji - sum_(i j) in mathcalA^+(i) q_ij = q_i^textrmdem  forall i in mathcalJ labeleqnncnlp-flow-conservation \n    underlineh_i leq h_i leq overlineh_i  forall i in mathcalJ labeleqnncnlp-head-bounds \n    underlineq_ij leq q_ij leq overlineq_ij  forall (i j) in mathcalA labeleqnncnlp-flow-bounds\nendalign","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"Here, Constraints eqrefeqnncnlp-head-loss are head loss relationships, Constraints eqrefeqnncnlp-head-source are head bounds at source nodes, Constraints eqrefeqnncnlp-flow-conservation are flow conservation constraints, Constraints eqrefeqnncnlp-head-bounds head bounds at junctions, and Constraints eqrefeqnncnlp-flow-bounds are flow bounds. Note that the sources of non-convexity and nonlinearity are Constraints eqrefeqnncnlp-head-loss.","category":"page"},{"location":"math-model.html#Convex-Nonlinear-Program-1","page":"Mathematical Models","title":"Convex Nonlinear Program","text":"","category":"section"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"Note that the sources of non-convexity and nonlinearity in the full non-convex formulation of the physical feasibility problem are Constraints eqrefeqnncnlp-head-loss. Because of the symmetry of the head loss relationship, the problem can be modeled instead as a disjunctive program. Here, the disjunction arises from the direction of flow, i.e.,","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"beginequation\n   left\n\tbeginalignedc\n\t\t h_i - h_j = L_ij r_ij q_ij^1 + alpha \n              q_ij geq 0\n\tendaligned\n   right\n   lor\n   left\n\tbeginalignedc\n\t\t h_i - h_j = L_ij r_ij (-q_ij)^1 + alpha \n              q_ij  0\n\tendaligned\n   right  forall (i j) in mathcalA labeleqndnlp-head-loss\nendequation","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"which replaces Constraints eqrefeqnncnlp-head-loss in the NCNLP formulation. To model the disjunction, each flow variable q_ij can be decomposed into two nonnegative flow variables, q_ij^+ and q_ij^-, where q_ij = q_ij^+ - q_ij^-. With this in mind, the following convex nonlinear program (CNLP) can be formulated, which is adapted from Section 3 of Global Optimization of Nonlinear Network Design by Raghunathan (2013):","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"beginalign\n     textminimize\n      sum_(i j) in mathcalA fracL_ij r_ij2 + alpha left(q_ij^+)^2 + alpha + (q_ij^-)^2 + alpharight - sum_i in mathcalS h_i^textrmsrc left(sum_(i j) in mathcalA^-(i) (q_ij^+ - q_ij^-) - sum_(j i) in mathcalA^+(i) (q_ji^+ - q_ji^-)right) \n     textsubject to\n      sum_(j i) in mathcalA^-(i) (q_ji^+ - q_ji^-) - sum_(i j) in mathcalA^+(i) (q_ij^+ - q_ij^-) = q_i^textrmdem  forall i in mathcalJ labeleqncnlp-flow-conservation \n       q_ij^+ q_ij^- geq 0  forall (i j) in mathcalA labeleqncnlp-flow-bounds\nendalign","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"renewcommandhat1widehat1","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"Suppose that hatmathbfq^+ hatmathbfq^- in mathbbR^lvert A rvert solves (CNLP) with the associated dual solution hatmathbfh in mathbbR^lvert mathcalJ rvert, corresponding to the flow conservation Constraints eqrefeqncnlp-flow-conservation, and hatmathbfu^+ hatmathbfu^- in mathbbR^lvert mathcalA rvert, corresponding to the nonnegativity Constraints eqrefeqncnlp-flow-bounds. This solution must satisfy the first-order necessary conditions","category":"page"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"beginalign\n    hath_i - hath_j = L_ij r_ij hatq_ij lvert q_ij rvert^alpha  forall (i j) in mathcalA \n    h_i = h_i^textrmsrc  forall i in mathcalS \n    sum_(j i) in mathcalA^-(i) q_ji - sum_(i j) in mathcalA^+(i) q_ij = q_i^textrmdem  forall i in mathcalJ \n    underlineh_i leq h_i leq overlineh_i  forall i in mathcalJ \n    underlineq_ij leq q_ij leq overlineq_ij  forall (i j) in mathcalA\nendalign","category":"page"},{"location":"math-model.html#Mixed-integer-Convex-Program-1","page":"Mathematical Models","title":"Mixed-integer Convex Program","text":"","category":"section"},{"location":"math-model.html#Mixed-integer-Linear-Program-1","page":"Mathematical Models","title":"Mixed-integer Linear Program","text":"","category":"section"},{"location":"math-model.html#Optimal-Network-Design-1","page":"Mathematical Models","title":"Optimal Network Design","text":"","category":"section"},{"location":"math-model.html#","page":"Mathematical Models","title":"Mathematical Models","text":"Currently, the primary formulation focuses on the problem of optimally designing a water distribution network. More specifically, given a network consisting of reservoirs, junctions, and pipes, the problem aims to select the most cost-effecient resistance from a discrete set of resistances for each pipe to meet demand over the entire network. The set of all possible resistances for a given pipe (i j) in mathcalA is denoted as mathcalR_ij, where each resistance is denoted as r in mathcalR_ij. A binary variable x^r_ijr is associated with each of these diameters to model the decision, i.e., x_ijr^r = 1 if r is selected to serve as the pipe resistance, and x_ijr^r = 0 otherwise. The cost per unit length of installing a pipe of resistance r is denoted as c_ijr.","category":"page"},{"location":"formulations.html#Network-Formulations-1","page":"Network Formulations","title":"Network Formulations","text":"","category":"section"},{"location":"specifications.html#Problem-Specifications-1","page":"Problem Specifications","title":"Problem Specifications","text":"","category":"section"},{"location":"model.html#Water-Model-1","page":"WaterModel","title":"Water Model","text":"","category":"section"},{"location":"objective.html#Objective-1","page":"Objective","title":"Objective","text":"","category":"section"},{"location":"variables.html#Variables-1","page":"Variables","title":"Variables","text":"","category":"section"},{"location":"constraints.html#Constraints-1","page":"Constraints","title":"Constraints","text":"","category":"section"},{"location":"relaxations.html#Relaxation-Schemes-1","page":"Relaxation Schemes","title":"Relaxation Schemes","text":"","category":"section"},{"location":"parser.html#File-I/O-1","page":"File I/O","title":"File I/O","text":"","category":"section"},{"location":"parser.html#","page":"File I/O","title":"File I/O","text":"CurrentModule = WaterModels","category":"page"},{"location":"parser.html#","page":"File I/O","title":"File I/O","text":"parse_epanet\nparse_file\nparse_json","category":"page"},{"location":"parser.html#WaterModels.parse_epanet","page":"File I/O","title":"WaterModels.parse_epanet","text":"parse_epanet(path)\n\nParses an EPANET (.inp) file from the file path path and returns a WaterModels data structure (a dictionary of data). See the OpenWaterAnalytics Wiki for a thorough description of the EPANET format and its components.\n\n\n\n\n\n","category":"function"},{"location":"parser.html#WaterModels.parse_file","page":"File I/O","title":"WaterModels.parse_file","text":"parse_file(path)\n\nParses an EPANET (.inp) or JavaScript Object Notation (JSON) file from the file path path, depending on the file extension, and returns a WaterModels data structure (a dictionary of data).\n\n\n\n\n\n","category":"function"},{"location":"parser.html#WaterModels.parse_json","page":"File I/O","title":"WaterModels.parse_json","text":"parse_json(path)\n\nParses a JavaScript Object Notation (JSON) file from the file path path and returns a WaterModels data structure (a dictionary of data).\n\n\n\n\n\n","category":"function"},{"location":"developer.html#Developer-Documentation-1","page":"Developer","title":"Developer Documentation","text":"","category":"section"},{"location":"experiment-results.html#WaterModels-Experimental-Results-1","page":"Experiment Results","title":"WaterModels Experimental Results","text":"","category":"section"}]
}
