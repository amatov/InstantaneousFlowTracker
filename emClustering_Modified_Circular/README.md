MATLAB m-files implementing the mixture fitting algorithm described in the paper M. Figueiredo and A.K.Jain, "Unsupervised learning of finite mixture models (IEEE 2002)"

It consists of a main MATLAB function called "mixtures4.m" and three auxiliary functions: "uninorm.m", "multinorm.m", and
"elipsnorm.m", which are called by the main program.

For instructions type "help mixtures4" at the MATLAB prompt, "demo1.m", uses the three component mixture
from the paper N. Ueda and R. Nakano, "Deterministic annealing EM algorithm (Neural Networks 1998)", "demo2.m", uses the "Simulated Set 2" from the book by McLachlan and Peel, 2000, page 218. The demos call a function "genmix.m", which generates samples from a Gaussian mixture.

The wrap around, circular clustering was implemented by Alexandre Matov and Shayan Modiri.
