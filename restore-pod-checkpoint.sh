newcontainer=$(buildah from scratch)
buildah add $newcontainer demo-counter.tar  /
buildah config --annotation=io.kubernetes.cri-o.annotations.checkpoint.name=demo-counter $newcontainer
buildah commit $newcontainer checkpoint-image:latest
buildah rm $newcontainer
buildah push localhost/checkpoint-image:latest docker.io/sumanpf9/democounter-restore:latest
buildah rmi localhost/checkpoint-image:latest


