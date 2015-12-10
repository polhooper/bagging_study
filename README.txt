Copyright (c), Polhooper Strategic LLC, 2015

*----------*
* CONTACT: * 
*----------* 

Email: info@polhooper.com
Phone: (619) 365-4231 

*-----------------* 
* ACKNOWLEDGMENTS *
*-----------------* 

All original scripts and data released under the Apache License 2.0 open source 
license. We gratefully acknowledge the contribution of the following open source 
projects, listed along with their respective open source licenses. We only cite 
the most significant bits of software utilized here. To suggest ammendments to the 
following list please email info@polhooper.com: 
* R Core Team (2015) R: A language and environment for statistical computing --  
  GNU General Public License 
* Python Software Foundation. Python Language Reference, version 2.7. Available at 
  http://www.python.org -- Python Software Foundation License 
* Scikit-learn: Machine Learning in Python, Pedregosa et al., JMLR 12, pp. 
  2825-2830, 2011 -- BSD license 
* Pandas, Wes McKinney. Data Structures for Statistical Computing in Python, 
  Proceedings of the 9th Python in Science Conference, 51-56 (2010) -- BSD license 

*-------* 
* NOTES * 
*-------* 

(A) Operating systems: 
We've written this demo for Unix/Linux systems. It should run as-is on OSX, 
Ubuntu, and Red Hat. Windows users are welcome to adopt the code and suggest edits
to the repo. 

(B) Software dependencies: 
IMPORTANT: You need sklearn v 0.17 or higher for this to run. Without updating 
your sklearn install this won’t work. 

We also assume that if you're able to run the code here you have a degree of 
specialist knowledge regarding data science in R/Python. We provide some tips
and resources for installing package dependencies, but we're counting on you 
knowing how to install this core software yourself. We highly encourage users 
to use a package manager when install new open source software, e.g. Homebrew
for OSX or apt-get for Ubuntu. 

(C) System requirements: 
This training data is relatively large, and this demo does best on medium-high 
performance systems. We used a Mac Mini quad core with 16GB RAM to develop this
example. With this system model training takes ~20 minutes. With less memory and 
fewer CPUs it will be quite a bit slower. 

If your system is getting bogged down, especially with RAM overload, try down-sampling the data  file to lighten the system load.  

*---------------*
* INSTRUCTIONS: * 
*---------------* 

(0) Install all dependencies: 
  (i) Python 2.7: 
    (a) Python 2.7 should have a native install on all Linux/Unix systems
    (b) Install SciPy (see http://www.scipy.org/install.html)
    (c) Install sklearn (see http://scikit-learn.org/stable/install.html) 
    (d) Install pandas (http://pandas.pydata.org/pandas-docs/stable/install.html) 
  (ii) R: 
    (a) Install R core software (see https://cran.r-project.org/, 
        https://cran.r-project.org/bin/linux/ubuntu/README, 
        http://www.r-bloggers.com/installing-r-on-os-x-100-homebrew-edition/) 
    (b) Missing R dependencies should auto-install when you run the study. If not, 
        you can install from command line via (example): 
        $ sudo R 
        > install.packages(c('readr', 'dplyr'))
        In some rare cases, e.g. if you’re working with Ubuntu OS, it may be 
        necessary to install dependencies from local source. plyr can be tricky. 
        Apologies in advance for any hassle here. 

(1) Clone the leadscore_whitepaper git repo:
    git clone https://bitbucket.org/apolhamus/bagging_study.git

(2) Download train.csv, train.vw, test.csv, and test.vw from 
    https://www.dropbox.com/sh/c4mycqb0kq4ozix/AABLtU1sn7_Ox3d1vFgbafjha?dl=0

(3) Create symlinks to data files from within the git repo, e.g. on OSX: 
  $ cd ../bagging_study
  $ ln -s ~/Downloads/train_ordered.csv train.csv
  $ ln -s ~/Downloads/test_ordered.csv test.csv
  
(4) Run routine once dependencies installed, repo cloned, and symlinks created: 
  $ cd ../bagging_study
  $ python run.py 
