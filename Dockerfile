FROM fedora:23
MAINTAINER http://github.com/alzadude/docker-fedora-ansible-test

# Install packages and set up sshd
RUN dnf -q -y install openssh-server python pwgen sudo
# TODO install of python-yumdaemon is temporary, it can be removed when I stop using yum module in tasks
RUN dnf -q -y install python-yumdaemon
RUN dnf clean all
#RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
#RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
#RUN ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
#RUN ssh-keygen -A
#RUN sed -i 's/#*UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g' /etc/ssh/sshd_config
#RUN sed -i 's/#*UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]

