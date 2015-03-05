A *production-ready* image of Wildfly 8.2.0 with Pentaho Reports for Odoo 
=========================================================================

This image weighs just over 1Gb. Keep in mind that WildFly is a flexible, lightweight, managed application runtime that helps you build amazing applications written in JAVA. We designed this image with built-in external dependencies and almost nothing useless. It is used from development to production on version 8.0 with various community addons as pentaho reporting runtime.

Pentaho & Wildfly version
=========================

This docker builds with a tested version of Wildfly 8.2 & pentaho-reporting.version=5.2.0.0-209 AND related dependencies. The packed versions of wildfly & pentaho have always been tested against our CI chain and are considered as production grade. We update the revision pretty often, though :)

Examples:
----------
  
  Run odoo V8 in the background as `xyz.wildfly` on 0.0.0.0:8080

	$ docker run --name="xyz.wildfly"  -it -d -p 8080:8080 docker/wildfly

  Run the V8 image with an interactive shell and remove the container on logout

  	$ docker run -ti --rm docker/wildfly bash

  Run the v8 image and tail log, then remove the container

	$ docker run --name="xyz.wildfly"  -it --rm -p 8080:8080 docker/wildfly
