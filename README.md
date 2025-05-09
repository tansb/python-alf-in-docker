This dockerfile is to run Gabe Brammer's alf-python wrapper to Charlie Conroy's Absorption Line Fitter (ALF) code.

The image will clone both the alf-python github and alf repos.

### Step 1: define your data dir
Docker containers are designed to work and operate in isolation, but when using ALF you need an easy way to pass data in and out. Therefore, specify a directory to mount into the container so you can access that data from within the container.

```export MY_MOUNTED_DATA_DIR=your_data_dir```

### Step 2: Build the docker image.
cd to the directory with the Dockerfile and the docker-compose.yml file. Do:
```docker compose up -d```

This builds the docker image called tans/alf and will create a (detatched) container called alf_container.

### Step 3: Enter the docker container
```docker exec -it alf_container bash```

This runs the alf container interactively with a bash shell.
Inside the container you should have a directory /opt/alf containing all the alf sourcecode, and opt/alf-python containing the python wrapper source code.

### !!!! Step 4: Copy the models into the /opt/alf/infiles/
The VCJ models that run with alf are not in the github repo. If you don't already have them, email charlie conroy nicely to ask for them.
ALF cannot run without the models.
If you have the files in your MY_MOUNTED_DATA_DIR, you can:
```scp /mnt/path_to_the_models_in_your_mounted_dir>/* /opt/alf/infiles/```

### Step 5 install Gabe Brammer's python-alf wrapper:
In the /opt/alf-python directory run:
```python3 setup.py install```

### Step 6 check that it's all running correctly:
Run ipython and see if you can:
from alf.alf import Alf
sps = Alf()

This should print something like:
Alf: CALL SETUP()
 Fit_type:           1
 fit_two_ages:           0
 mwimf:           1
 imf_type:           1
 maskem:           1
 fit_hermite:           0
 velbroad_simple:           0
 Wavelength limits l1, l2, nlint:   3590.1199999999999        11079.600000000000                1

If so, then you are ready to use Alf and the python-wrapper :)
