# kubecon-demo-india-hyd
Demo presented on Forensic Container Checkpointing with CRI-U

# 🛠️ Pre-requisites

To use this project, ensure your Kubernetes environment meets the following configuration and runtime requirements.

---

## ✅ Kubernetes Cluster

- Kubernetes version must be **v1.25 or later**

---

## ⚙️ Container Runtime: CRI-O

Ensure that your Kubernetes nodes are configured to use **CRI-O** as the container runtime.

---

## 🚩 Enable Feature Gate: `ContainerCheckpoint`

The Kubelet must be started with the `ContainerCheckpoint` feature gate enabled.

### 🔧 Example Configuration

Edit your kubelet systemd configuration (commonly located at `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`) and add:

```bash
--feature-gates=ContainerCheckpoint=true
```

## 🚩 Enable Settings for CRI-U in CRI-O

The CRI-O must be started with the following settings enabled

### 🔧 Example Configuration

Edit the CRI-O configuration (commonly located at `/etc/crio/crio.conf`) and add:

```bash
enable_criu_support = true    #Enable Checkpointing
drop_infra_ctr = false        #Enable Restore into another pod
```

## 🚩 Install checkpointctl & crit
Ref - https://github.com/checkpoint-restore/checkpointctl

## 📝 Instructions to test the demo

* Clone repository <br/>
```bash
git clone https://github.com/suchakra012/kubecon-demo-india-hyd.git
```

* Create the pod (demo-counter) using demo-counter.yaml
```bash
cd kubecon-demo-india-hyd
kubectl create ns demo-kubecon
kubectl apply -f demo-counter.yaml
curl <Pod_IP>:8088  #Generate some requests to increment counter value
```

* Snapshot the current state of the pod
```bash
curl -sk -X POST  "https://localhost:10250/checkpoint/demo-kubecon/demo-counter/demo-counter" --key /etc/kubernetes/pki/apiserver-kubelet-client.key --cacert /etc/kubernetes/pki/ca.crt --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt
```
```bash
cp /var/lib/kubelet/checkpoints/<snapshot_timestamp_file.tar> demo-counter.tar
```


* Use checkpointctl to analyze the conatiner snapshot & its process
```bash
checkpointctl show demo-counter.tar #Provide the checkpointed info
checkpointctl inspect demo-counter.tar --stats #Summary info about the checkpoint
checkpointctl inspect demo-counter.tar --all #Inspect Low level info
checkpointctl memparse demo-counter.tar --pid 1 | head #Inspect memory pages for first PID 1
crit show checkpoint/pstree.img #Inspect the process on the container
```

* Restore the snapshot state back into another pod
```bash
sh restore-pod-checkpoint.sh
kubectl apply -f demo-restore-counter.yaml
``` 

  
 
