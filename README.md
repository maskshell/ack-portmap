# PortMap for Alibaba ACK

Add port mapping support for terway on Alibaba Cloud Container Service for Kubernetes (ACK).

## Build Example

```shell
docker buildx build \
       --tag registry.address.fix.me/portmap:v1.3.0 \
       --builder container \
       --platform linux/arm64,linux/amd64 \
       --progress plain \
       --push \
       .
```

## Usage Example

Add a new ConfigMap for new init container.

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: eni-config-cni
  namespace: kube-system
data:
  0-terway.conflist: |-
    {
        "cniVersion": "0.3.0",
        "name": "terway",
        "plugins": [
            {
                "type": "terway"
            },
            {
                "type": "portmap",
                "capabilities": {
                    "portMappings": true
                }
            }
        ]
    }
```

Add an init container to terway's deployment config yaml.

```yaml
      initContainers:
# Add a new init container
        - name: terway-portmap-init
          command:
            - sh
            - '-c'
            - >-
              cp /portmap /opt/cni/bin/;
              chmod +x /opt/cni/bin/portmap;
              cp /etc/eni/0-terway.conflist /etc/cni/net.d/
          image: 'registry.address.fix.me/portmap:v1.3.0'
          securityContext:
            privileged: true
            procMount: Default
          volumeMounts:
            - name: cni-bin
              mountPath: /opt/cni/bin/
            - name: configvolume-cni
              mountPath: /etc/eni
            - name: cni
              mountPath: /etc/cni/net.d/
# DO NOT modify the original volumes config, just add new elements for new configMap.
# Digital pre set in default file name is 10-terway.conf, and new file name is 0-terway.conflist
# 0 < 10, this makes sure the file 0-terway.conflist will be load.
      volumes:
        - name: configvolume-cni
          configMap:
            name: eni-config-cni
            items:
              - key: 0-terway.conflist
                path: 0-terway.conflist
            defaultMode: 420
```

## Trouble Shooting

Find out port mapping status.

```Shell
iptables -t nat -vnL | grep CNI
```

Delete the CNI hostport related iptables Rules, Chains, and then recreate the pod that use the hostPort.

```Shell
iptables -t nat -D xxxx n
iptables -t nat -X xxxx
```
