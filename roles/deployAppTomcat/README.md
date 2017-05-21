# gl.app-deploy-tomcat #

Ce rôle permet de déployer une application (war) sur les instances tomcat installées.

## Variables ##

#### Obligatoires #### 

- **app_group** : groupe maven de l'artefact, ex: com/galerieslafayette
- **app_name** : nom maven de l'artefact (doit être un war), ex: units-repository-webapp
- **app_version** : version maven de l'artefact, ex: 1.0
- **app_context** : contexte de déploiement de l'application (sans le /), ex: units-repository

#### Facultatives ####

- **artifactory_url** : url de base de Artifactory, par défaut: http://soleil.int-gl.com/artifactory
- **app_repository** : Répository où récupérer le war sur Artifactory, par défaut: si **app_name** se termine par SNAPSHOT alors **snapshots-local** sinon **releases-local**
- **tomcat_restart_after_deploy** : démarrer tomcat apres le déploiement ? , par défaut : true
- **install_middleware** : permet de dire si toute la couche middleware doit être installée ou non, par défaut : true

#### Exposées (variables disponibles pour les playbooks) ####

...
 
 
## Dependences de roles ##

- gl.tomcat

## requirements.yml ##

    - name: gl.setup
      src: http://soleil.int-gl.com/artifactory/gm-socle-technique/com/galerieslafayette/socle/ansible/roles/gl.setup/2.0/gl.setup-2.0.tar.gz
    - name: gl.jdk
      src: http://soleil.int-gl.com/artifactory/gm-socle-technique/com/galerieslafayette/socle/ansible/roles/gl.jdk/2.0/gl.jdk-2.0.tar.gz
    - name: gl.tomcat
      src: http://soleil.int-gl.com/artifactory/gm-socle-technique/com/galerieslafayette/socle/ansible/roles/gl.tomcat/2.0/gl.tomcat-2.0.tar.gz
    - name: gl.app-deploy-tomcat
      src: http://soleil.int-gl.com/artifactory/gm-socle-technique/com/galerieslafayette/socle/ansible/roles/gl.app-deploy-tomcat/2.0/gl.app-deploy-tomcat-2.0.tar.gz

## Version ##
1.0 : 04 sept 2015
 
## Contacts ##
* [Oualid BOURGOU](mailto:obourgou.ext@galerieslafayette.com)
* [Damien MARIAGE](mailto:dmariage.ext@galerieslafayette.com)
