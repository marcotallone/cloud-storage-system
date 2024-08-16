# Exercise 3: MPI Service in Kubernetes

> Cloud Advanced

This files contains the instructions and the necessary steps to deploy and run
the [OSU Benchmark](https://mvapich.cse.ohio-state.edu/benchmarks/) test in a Kubernetes cluster set up using [Vagrant](https://www.vagrantup.com/).\
All the necessary files are provided in this folder, which follows the following
structure:

```zsh
 .
├──  benchmarks # OSU Benchmark files and results
│  ├──  bcast-one-node.yaml
│  ├──  bcast-two-nodes.yaml
│  ├──  benchmark.sh
│  ├──  convert.py
│  ├──  p2p-one-node.yaml
│  ├──  p2p-two-nodes.yaml
│  ├──  results.csv
│  └──  results.txt
├──  docker # Docker files
│  ├──  Dockerfile
│  ├──  openmpi-builder.Dockerfile
│  ├──  openmpi.Dockerfile
│  └──  osu-code-provider.Dockerfile
├── 󰗀 kub-devel-network.xml # Network configuration file
├──  network.sh
├──  scripts # Vagrant provisioning scripts
│  ├──  0_common.sh
│  ├──  1_master.sh
│  ├──  2_worker.sh
│  ├──  3_credentials.sh
│  ├──  4_docker.sh
│  ├──  flannel.sh
│  └──  mpi.sh
├── 󰢬 ssh # SSH keys
│  ├── 󰌆 id_rsa
│  └── 󰷖 id_rsa.pub
└── ⍱ Vagrantfile
```

## Requirements

The deployment of this project requires the following:

- [Vagrant](https://www.vagrantup.com/)
- [Libvirt](https://libvirt.org/)
- `vagrant-libvirt` plugin, which can be installed through the following command:

```zsh
vagrant plugin install vagrant-libvirt
```

> [!NOTE] For **Archlinux** users it might helpful to know that the libvirt plugin is not compatible with the ruby gems as currently shipped with the vagrant package in the Arch repos (which are up-to-date). This might cause an error such as Vagrant failed to properly resolve required dependencies. An alternative in order to use this plugin without such issues, is to use the container image via either Podman or Docker, as shown in the [official documentation](https://vagrant-libvirt.github.io/vagrant-libvirt/installation.html#docker--podman). Source: [Archwiki](https://wiki.archlinux.org/title/Vagrant) (July, 2024).

## Installation

The installation phase consists in 3 steps:

1. Creating and Provisioning the virtual machines
2. Installing the MPI Operator
3. Deploying flannel

### 1. Provisioning

It's first necessary to define the network which can be done using the [provided
script](./network.sh) and giving sudo priviledges:

```zsh
./network up
```

Then, to deploy the Kubernetes cluster in the Vagrant virtual machines, run the following command:

```zsh
vagrant up --no-parallel
```

This will set-up two nodes running a `Fedora/39-cloud-base` box as specified in
the [Vagrantfile](./Vagrantfile).
The `--no-parallel` flag guarantees that the master node will be set-up before
the worker one.\
Once the installation phase concludes, you can ssh into either node (`k01` or
`k02`) with:

```zsh
vagrant ssh k01
# or vagrant ssh k02
```

and then check the status of the cluster either with the `k9s` utility or by running:

```zsh
[vagrant@k01 ~] kubectl get nodes
```

### 2. MPI Operator Installation

Once the nodes are running with the dedicated services it's possible to deploy
the [MPI Operator](https://github.com/kubeflow/mpi-operator). The usage of such
operator actually requires [specialized containers](https://github.com/kubeflow/mpi-operator/tree/master/build/base) to compile and run the
benchmark test before its deployment. Thankfully, these have been already
imported and compiled in the previous step (see the
[`script/4_docker.sh`](./scripts/4_docker.sh) provisioning script). To check the
existence of such container images on the virtual machines one can run:

```zsh
[vagrant@k01 ~] podman images -a
```

Having confirmed this, according to documentation, the MPI Operator can be installed by directly applying the dedicated manifests to the Kubernetes nodes. This task is simplified by running the provided [`mpi.sh`](./scripts/mpi.sh) script inside the master node (`k01`):

```zsh
[vagrant@k01 ~] ./mpi.sh
```

### 3. Flannel Deployment

The last step consists in deploying the flannel network to the Kubernetes
cluster. This can be done by running the [dedicated
script](./scripts/flannel.sh) on the master node:

```zsh
[vagrant@k01 ~] ./flannel.sh
```

After the deplyoment, it's necessary to reboot the virtual machine to apply the
necessary changes. From your host machine, please run:

```zsh
vagrant reload
```

> [!WARNING] **Not rebooting** the virtual machines will lead to error messages
> later displayed when running the benchmark tests, hence this step is strictly
> necessary!

## Running the Benchmark

The [benchmarks](./benchmarks/) folder copied inside the kubernetes nodes provides the
necessary `yaml` manifests to run the following osu latency tests:

- [`p2p-one-node`](./benchmarks/p2p-one-node.yaml): point to point latency test with
  two workers on the same node
- [`p2p-two-nodes`](./benchmarks/p2p-two-nodes.yaml): point to point latency
with two workers placed one per node
- [`bcast-one.node`](./benchmarks/bcast-one-node.yaml): broadcast latency test with
  two workers on the same node
- [`bcast-two-nodes`](./benchmarks/bcast-two-nodes.yamlst): point to point latency
with two workers placed one per node

The tests can be performed using the provided [`benchmark.sh`](./benchmarks/benchmark.sh) script. This script will run the tests and save the results in a `results.txt` file. To run the tests, simply run the following commandas:

```zsh
[vagrant@k01 ~] cd benchmarks
[vagrant@k01 ~/benchmarks] ./benchmark.sh <test-name.yaml>
```

where `<test-name.yaml>` is the name of the test you want to run. For example, to run the point to point latency test with two workers on the same node, you would run:

```zsh
[vagrant@k01 ~/benchmarks] ./benchmark.sh p2p-one-node.yaml
```

Results of the tests are then converted in `csv` format by the
[`convert.py`](./benchmarks/convert.py) script to be later analyzed with ease.

## Cleaning Up

To clean up and remove the virtual machine once you are done, you can run:

```zsh
vagrant destroy -f
```

from your host machine and all the resources will be removed.
