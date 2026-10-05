## Примітка щодо розгортання

Через відсутність можливості верифікувати банківську картку для AWS, 
EC2-сервер замінено на локальний SSH-сервер (WSL/Ubuntu), доступний 
ззовні через тунель serveo.net. 

Логіка CI/CD-пайплайна (SSH-ключ через GitHub Secrets, rsync-копіювання 
файлів, запуск через pm2) повністю ідентична до варіанту з EC2 - 
відрізняється лише адреса та порт підключення (вказуються як секрети 
EC2_HOST і EC2_PORT).

Успішний запуск пайплайна: GitHub Actions -> workflow "CI"->
run #7 "Final retry after fixing sudo and installing node/pm2".


## Оновлення (практична 9)

Застосунок контейнеризовано через Docker. Образ збирається з тегом хешу 
останнього коміту (git rev-parse --short HEAD) і заливається на Docker Hub. 
Деплой на сервер відбувається через docker-compose, який піднімає разом 
Node.js-застосунок і PostgreSQL. pm2 повністю видалено з сервера.

Через використання тимчасового SSH-тунелю (serveo.net) замість постійного 
EC2-сервера, пайплайн іноді потребує повторного запуску, якщо тунель 
встигає "заснути" через ліміт бездіяльності (2 хв). Успішний запуск: 
GitHub Actions -> workflow "CI" -> "Retry compose deploy".

## Оновлення (практична 12) - Terraform / IaC

Згідно із завданням, Terraform мав керувати інфраструктурою AWS (Security 
Group, EC2-інстанс). Через відсутність можливості верифікувати банківську 
картку для AWS, хмарний провайдер замінено на Terraform Docker Provider 
(kreuzwerker/docker), що зберігає всі принципи інфраструктури як коду (IaC):

- `provider "aws"` -> `provider "docker"`
- `aws_security_group` (порти 22, 3000) -> `docker_network` — ізольована 
  мережа для контейнера; порт 3000 відкривається через блок `ports` у 
  `docker_container`
- `aws_instance` (ami, instance_type, key_name) -> `docker_container` 
  (image, name, ports)
- `variables.tf` (регіон, AMI, шлях до ключа) -> `variables.tf` (назва 
  образу, назва контейнера, порт)
- `outputs.tf` (instance_ip) -> `outputs.tf` (app_url - адреса, де 
  доступний застосунок)

Повний цикл Terraform (init, plan, apply, destroy) виконується як 
локально для перевірки, так і автоматично через GitHub Actions при 
кожному push у main: пайплайн копіює папку terraform/ на сервер по SSH 
і виконує terraform init + terraform apply -auto-approve з підстановкою 
актуального тега Docker-образу (хеш останнього коміту).

Замість оновлення секрету EC2_HOST (сервер лишається тим самим — 
локальний WSL через SSH-тунель serveo.net), Terraform керує тим, який 
саме образ розгорнутий у контейнері на цьому сервері - це і є той самий 
принцип "декларативної інфраструктури", який вимагає завдання, просто 
застосований до Docker-середовища замість AWS EC2.
