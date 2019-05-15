image_base = "futebol-exp22-base"

instances = [
  {
    instance_name = "is-rabbitmq"
    flavor_name   = "p1.large"
    ip_address    = "10.61.1.10"
    mac_address   = "fa:16:3e:f5:23:7e"
  },
  {
    instance_name = "is-camera-gateway-01"
    flavor_name   = "p1.medium"
    ip_address    = "10.61.1.249"
    mac_address   = "fa:16:3e:6f:28:3d"
  },
  {
    instance_name = "is-camera-gateway-23"
    flavor_name   = "p1.medium"
    ip_address    = "10.61.1.248"
    mac_address   = "fa:16:3e:ce:e1:1f"
  },
  {
    instance_name = "is-image-processing"
    flavor_name   = "p1.large"
    ip_address    = "10.61.1.246"
    mac_address   = "fa:16:3e:67:fb:15"
  },
  {
    instance_name = "is-robot-controller"
    flavor_name   = "p1.small"
    ip_address    = "10.61.1.245"
    mac_address   = "fa:16:3e:7e:75:83"
  },
  {
    instance_name = "is-sdn-controller"
    flavor_name   = "m1.small"
    ip_address    = "10.61.1.243"
    mac_address   = "fa:16:3e:2c:af:d0"
  },
  {
    instance_name = "is-mjpeg-server"
    flavor_name   = "m1.small"
    ip_address    = "10.61.1.247"
    mac_address   = "fa:16:3e:5e:94:4b"
  },
]
