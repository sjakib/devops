# tomcat-gl #

Ce rôle permet de déployer une ou plusieurs instance de **Apache Tomcat**.

## Variables ##

#### Obligatoires #### 

- **project_name** : nom du projet
- **tomcat** : contient la liste des instances à deployer, pour chaque instance srv_num designe le nom de l'instance (server[srv_num]) alors que le port_offset sert d'index dans la creation des numeros de ports, ex port http = [tomcat_app_port_offset][port_offset]080 : (srv01=11080, srv02=12080)

        tomcat: {
            instances: [
              {srv_num: '01', port_offset: 1},
              {srv_num: '02', port_offset: 2},
            ]
        }

#### Facultatives ####

- **gl_env**: nom de l'environnement, ex: dev, inf5, int, inf6, rec
- **tomcat_major_version** : numéro de version majeure, par defaut : '8'
- **tomcat_minor_version** : numéro de version mineure, par defaut : '0'
- **tomcat_micro_version** : numéro de revision, par defaut : '23'
- **tomcat_system_username** : nom du user systeme a créer pour tomcat, par défaut
- **tomcat_system_usergroup** : nom du group systems auquel doit appartenir le user ci-dessus, par défaut: tomcatg
- **tomcat_app_port_offset** : designe le numero de l'application sur la machine (utilisé lors de la création des numéros de ports des instances, 1er digit), chaque application doit avoir son propre offset
- **tomcat.http_params**: liste d'attributs additionnels pour le connecteur http
- **tomcat_jmx_admin_password**: force le mot de passe de l’utilisateur admin;
- **tomcat_with_jmx_secure**: à « True » par défaut, ça permet de désactiver l’authentification JMX
        tomcat: {
          ...
          http_params: { maxPostSize: 2097152, connectionTimeout: 20000 },
        }

- **tomcat.ajp_params**: liste d'attributs additionnels pour le connecteur ajp

        tomcat: {
          ...
          ajp_params: { connectionTimeout: 20000 },
        }
        
- **tomcat.setenv_file**: path d'un script que le rôle pousse sur chaque instance de serveur Tomcat comme fichier setenv.sh (si présent dans le playbook). Attention, ne pas mettre la configuration JMX dans ce fichier, sinon la config est utilisée aussi lors du shutdown !

        tomcat: {
          ...
          setenv_file: "templates/tomcat/bin/mysetenv.sh",
        }

- **tomcat_app_java_opts** : liste de parametres applicatifs (equivaut aux jvm options -D), ces valeurs seront positionnées dans le catalina.properties, ex:

        tomcat_app_java_opts:
            - log4j.configuration={{app_base_dir}}/data/conf/log4j.properties
            - es.service.url=http://1.2.3.4/es/service

- **with_appdynamics** : install and configure AppDynamics agent on cluster nodes, par défaut: False
- **with_pinpoint** : install and configure PinPoint agent on cluster nodes, par défaut: False
- **agent_application_name** : Le nom de l'application pour l'agent, par défaut: **project_name**
- **appdynamics_tier_name** : le nom du 'tier' pour l'agent, par défaut: **project_cluster_name**
- **appdynamics_controller_host**: le hostname du master AppDynamics, par défaut: 192.168.46.64
- **appdynamics_controller_port**: le port du master AppDynamics, par défaut: 8090

#### Exposées (variables disponibles pour les playbooks) ####

- **tomcat_version** : version de tomcat, ex: 8.0.23
- **tomcat_location** : répertoire de base de tomcat (CATALINA_HOME)
- **tomcat_instances** : contient pour un host donné, la liste des instances avec le détail de chacune (home, base, http_port, ajp_port,...)
 
        tomcat_instances: [
            {
                "ajp_port": "11991", 
                "close_port": "11005", 
                "http_port": "11080", 
                "https_port": "11443", 
                "jmx_port": "11990", 
                "app_port_offset": "1",  
                "port_offset": "1", 
                "srv_name": "server01", 
                "srv_num": "01", 
                "tomcat_base": "/app/fast/cluster_IHM/server01", 
                "tomcat_home": "/app/fast/tomcat", 
                "webapps_dir": "/app/fast/cluster_IHM/server01/webapps"
            }, 
            {
                "ajp_port": "12991", 
                "close_port": "12005", 
                "http_port": "12080", 
                "https_port": "12443", 
                "jmx_port": "12990", 
                "app_port_offset": "1",  
                "port_offset": "2", 
                "srv_name": "server02", 
                "srv_num": "02", 
                "tomcat_base": "/app/fast/cluster_IHM/server02", 
                "tomcat_home": "/app/fast/tomcat", 
                "webapps_dir": "/app/fast/cluster_IHM/server02/webapps"
            }
        ]

## Templates ##

- **templates/tomcat/server-include.xml** : si présent dans le playbook, le contenu du fichier (en mode template) est ajouté dans la balise **<Host />** du fichier **server.xml**, permet notament de déclarer des contexts et des datasources au niveau serveur.

- **templates/tomcat/server-realm.xml** : si présent dans le playbook, le contenu du fichier (en mode template) est ajouté dans la balise **<Realm />** du fichier **server.xml**, permet notament de déclarer des contexts 'Realm' au niveau serveur.
 

 
## Contacts ##
* [JAKIB Sabir](mailto:sabir.jakib@gmail.com)

