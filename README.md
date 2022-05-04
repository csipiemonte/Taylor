# Taylor

*Taylor* è una soluzione destinata alla PA per la gestione della relazione con il cittadino e delle sue richieste.
Una piattaforma con un efficace backoffice per la gestione dei ticket e con varie canalità di comunicazione, che vanno dalle API alla mail, dalla chat al portale di supporto al cittadino. Un sistema di intelligenza artificiale permette di fornire risposte automatiche al cittadino che adopera la chat come mezzo di contatto, spostando così ad un livello successivo l'interazione diretta fra operatore e cittadino. 

Taylor si basa sul prodotto opensource [Zammad](https://github.com/zammad/zammad/), distribuito con la versione 3 della licenza GNU AFFERO General Public License (GNU AGPLv3).

## Prerequisiti

### Prerequisiti Software (client)

Sebbene Taylor sia un'applicazione Web, per far sì che funzioni correttamente, è necessario che siano soddisfatti alcuni requisiti lato client, come la compatibilità dei browser riportata nell'elenco qui sotto:
*  Firefox 78+
*  (Google) Chrome 83+
*  Tutti i browser basati su Chromium, come Microsoft Edge
*  Opera 69+
*  Safari 11

#### Requisiti server

##### Linguaggio di programmazione Ruby
------------
Taylor necessita di Ruby, tutte le rubygems richieste per la corretta installazione dell'applicazione sono elencate nel Gemfile. La versione di Ruby richiesta è la **2.7.4**

##### Distribuzioni supportate
------------
Taylor funziona su distribuzione "CentOS", nella versione **7.6**.

##### Dipendenze di pacchetto
------------
Qui di seguito sono riportate le dipendenze che devono essere installate sulla VM oggetto dell'installazione Taylor:
```
$ yum install epel-release
$ yum install imlib2
```

##### Database Server
--------------------
Taylor memorizza tutti i contenuti in un database PostgreSQL, versione **9.6**.

   **Taylor necessita della codifica UTF-8 per il database impiegato.**

##### Node.js
------------
Node.js (versione **14**) è richiesto da Taylor per la compilazione degli asset che avviene eseguendo ``rake assets:precompile``. Per installare Node.js si esegue:
```
# yum localinstall https://repo.ecosis.csi.it/artifactory/rpm-csi-local/Middleware/nodejs/nodejs-14.18.2-1nodesource.x86_64.rpm
```

##### Reverse Proxy
------------
Come Reverse Proxy, Taylor usa Apache versione **2.4**.

##### Elasticsearch
-----------------------------
Taylor utilizza Elasticsearch per
1.  rendere le ricerche più veloci
2.  supportare funzionalità avanzate come i reports
3.  ricercare nei contenuti allegati alle mail

La versione di Elasticsearch installata in Taylor è la **7.9**

### Prerequisiti Hardware
#### Ambiente di test, predisposto con:
4 CPU cores da 2194.842 MHz ciascuna

8 GB of RAM

#### Ambiente di produzione, predisposto con:
16 CPU cores da 2399.996 MHz ciascuna

24 GB of RAM

## Installing & Getting Started
### Elasticsearch
Elasticsearch è una dipendenza di Taylor e, come tale, deve essere predisposta prima che avvenga l'installazione di Taylor:

```
$ rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
$ echo "[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md"| tee /etc/yum.repos.d/elasticsearch-7.x.repo
$ yum install -y elasticsearch
$ /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-attachment
```

Dopo avere installato Elasticsearch e il suo plugin relativo agli allegati, è necessario abilitare e avviare il servizio:

```
$ systemctl start elasticsearch
$ systemctl enable elasticsearch
```

### Utente zammad

Aggiungere l'utente zammad:

```
$ useradd zammad -m -d /opt/zammad -s /bin/bash
$ groupadd zammad
```

### Installazione di Taylor

#### Step 1: download dei sorgenti
Prelevare l'ultima versione stabile di Taylor:

```
$ cd /opt
$ wget https://github.com/csipiemonte/Taylor/archive/stable.tar.gz
$ tar -xzf stable.tar.gz --strip-components 1 -C zammad
$ chown -R zammad:zammad zammad/
$ rm -f stable.tar.gz
```

#### Step 2: installazione delle dipendenze

Taylor necessita della versione 2.7.4 di Ruby, installata mediante l'eseguibile *rbenv* che deve essere presente sulla macchina.

```
$ rbenv install 2.7.4
```

Il riferimento alla versione 2.7.4 deve essere presente nel file *.bash_profile* dell'utente zammad

```
export RBENV_VERSION=2.7.4
```

E poi si installano bunlder, rake e rails:

```
su - zammad
$ gem install bundler rake rails
```

In ultimo, si esegue:
```
su - zammad
$ cd /opt/zammad
$ bundle install
```

per scaricare ed installare le librerie di terze parti elencate del Gemfile.

#### Step 3: configurazione del database
Creare il database destinato a Taylor ed con i relativi parametri (host, port, database, user, password) completare la configurazione del file `config/database.yml`:

```
su - zammad
$ cd /opt/zammad
$ cp config/database/database.yml config/database.yml
$ vi config/database.yml
```

Un esempio di configurazione per il file *config/database.yml* può essere:

```
development:
   adapter: postgresql
   database: zammad
   pool: 50
   timeout: 5000
   encoding: utf8
   host: host-db-postgresql
   port: 5432
   username: zammad
   password: changeme
```

#### Step 4: inizializzazione del database

```
su - zammad
$ cd /opt/zammad
$ rake db:migrate
$ PRODUCT_LINE=csi rake db:seed
```

#### Step 5: Pre compilazione degli assets

```
su - zammad
$ cd /opt/zammad
$ rake assets:precompile
```

#### Step 6: installazione di Taylor come servizio

```
su - zammad
$ cd /opt/zammad/script/systemd
$ ./install-zammad-systemd-services.sh
```

#### Step 7: connessione di Elasticsearch a Taylor

```
su - zammad
$ cd /opt/zammad
$ rails r "Setting.set('es_url', 'http://url_elasticsearch:9200')"
$ rake searchindex:rebuild
```

## Versioning
Per la gestione del codice sorgente viene utilizzata la metodologia [Semantic Versioning](https://semver.org/).

## Authors
https://github.com/csipiemonte/Taylor/graphs/contributors

## Copyrights
(C) Copyright 2022 CSI Piemonte

## License
Questo software è distribuito con licenza GNU AFFERO GENERAL PUBLIC LICENSE Versione 3.

Consulta il file [LICENSE](LICENSE) per i dettagli sulla licenza.

In [Bom.csv](Bom.csv) è presente l'elenco delle librerie esterne utilizzate corredate della licenza di distribuzione.
