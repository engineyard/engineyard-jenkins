#
# Cookbook Name:: hudson_slave
# Recipe:: default
#

hudson_slave({
  :master => {
    :host => "ec2-174-129-24-134.compute-1.amazonaws.com",
    :port => 80,
    :public_key => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6AWDDDJcsIrY0KA99KPg+UmSjxjPz7+Eu9mO5GaSNn0vvVdsgrgjkh+35AS9k8Gn/DPaQJoNih+DpY5ZHsuY1zlvnvvk+hsCUHOATngARNs6yQMf2IrQqf38SlBPJ/xjt4oopLyqZuZ59xbFMFa0Yr/B7cCpxNpeIMCbwmc8YOtztOG1ZazlxB6eMTwp1V25TxFPh3PqUz9s37NmBEhkRiEyiJzlDSrKwz2y+77VWztQByM30lYAEXc5GwJD1LTaQwlv/thjhwveAzKLIpxzC5TbUjii7L+4iJF/JrjtXAEYmkegXj6lGBpRIdwXTYWMm3jG6gG+MV2nfWmocDzg3Q==",
    :master_key_location => "/home/deploy/.ssh/id_rsa"
  },
  :gem => {
    :install => "hudson --pre",
    :version => "hudson-0.3.0.beta.16"
  }
})