#Inspiration 1: https://github.com/jboss-dockerfiles/wildfly

FROM fedora:21
MAINTAINER Arun T K <arun.kalikeri@xxxxxxxx.com>

# Execute system update
RUN yum -y update && yum clean all

# Set the Language
RUN yum -y reinstall glibc-common 
RUN sed -i -- 's/en_US.UTF-8/en_IN.utf8/g' /etc/locale.conf
RUN source /etc/locale.conf # apply new setting
ENV LANG en_IN.utf8

# Install Microsoft fonts & necessary packages in Fedora 21
Add https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm /tmp/
RUN yum install -y /tmp/msttcore-fonts-installer-2.6-1.noarch.rpm xmlstarlet saxon augeas bsdtar unzip tar
RUN rm /tmp/msttcore-fonts-installer-2.6-1.noarch.rpm

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on Fedora/RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss
# Set the working directory to jboss' user home directory
WORKDIR /opt/jboss
# Specify the user which should be used to execute all commands below
USER jboss

# User root user to install software
USER root
# Install necessary packages
RUN yum -y install java-1.8.0-openjdk-devel && yum clean all

# Switch back to jboss user
USER jboss
# Set the JAVA_HOME variable to make it clear where Java is located
ENV JAVA_HOME /usr/lib/jvm/java

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 8.2.0.Final

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME && curl http://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz | tar zx && mv $HOME/wildfly-$WILDFLY_VERSION $HOME/wildfly

# Set the JBOSS_HOME env variable
ENV JBOSS_HOME /opt/jboss/wildfly

# Uncomment below line to set the admin user & password
#RUN /opt/jboss/wildfly/bin/add-user.sh admin Pass#3556 --silent

# Increasing Initial heap size & Maximum heap size
RUN sed -i -- 's/JAVA_OPTS="-Xms64m -Xmx512m/JAVA_OPTS="-Xms1024m -Xmx2048m/g' /opt/jboss/wildfly/bin/standalone.conf

# Enable binding to all network interfaces and debugging inside the EAP
RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> /opt/jboss/wildfly/bin/standalone.conf

# Add Odoo Pentaho module
ADD https://googledrive.com/host/0Bz-lYS0FYZbIfklDSm90US16S0VjWmpDQUhVOW1GZlVOMUdXb1hENFFBc01BTGpNVE1vZGM/pentaho-fedora21.war /opt/jboss/wildfly/standalone/deployments/

# User root user to cahnge permission
USER root
RUN chown jboss:jboss /opt/jboss/wildfly/standalone/deployments/pentaho-fedora21.war
RUN chmod 644 /opt/jboss/wildfly/standalone/deployments/pentaho-fedora21.war

# Switch back to jboss user
USER jboss

# Expose the ports we're interested in
EXPOSE 8080 9990

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
