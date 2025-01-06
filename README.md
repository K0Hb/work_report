# WorkReport

## Внимание

Программа является моей реализацией курсового проекта от автора [Юрия Жлоба](https://github.com/yzh44yzh). С поставленной задачей и вводными, можете ознакомиться по [ссылке](https://github.com/yzh44yzh/elixir_course/tree/master/project_01/work_report).

## Суть проекта

Всем хорошо знакома такая простая вещь, как TODO-list: список задач. Он может быть простым текстовым файлом, а может быть сложной системой, координирующей работу больших комманд, как, например JIRA.

Мы будем делать похожую вещь -- DONE-list. То есть список задач, которые уже сделаны. Зачем нужен такой список? Чтобы формировать по нему отчеты и анализировать нашу продуктивность.

Да, эту функцию может выполнять та же JIRA. Но это слишком громоздкий инструмент для индивидуального использования. Попробуем другой подоход.

Я делаю DONE-list, или report, в текстовом файле в формате markdown. Выглядит это так:

```markdown
# May

## 3 mon
[DEV] Review Pull Requests - 27m
[COMM] Daily Meeting - 15m
[DEV] Implement filters for Logstash - 39m
[DEV] Implement filters for Logstash - 57m
[OPS] Setup Elasticsearch - 39m
[OPS] Setup Kibana - 17m
[DEV] Learn how to search for logs in Kibana - 34m
[DOC] Write a document about logs in ELK - 22m

## 4 tue
[COMM] Daily Meeting - 31m
[DOC] TASK-42 Read BA documents - 15m
[DOC] Read Service T API documents - 19m
[COMM] Sprint Review & Retro - 1h 35m
[DOC] Read Service T API documents - 11m
[DEV] TASK-42 Implement feature - 46m
[DEV] TASK-42 Test - 22m
[DEV] TASK 42 Fix and test - 37m

## 5 wed
[DEV] Review Pull Requests - 39m
[COMM] Daily Meeting - 16m
[DEV] Task-43 Impletent feature - 31m
[DEV] Task-43 Impletent feature - 54m
[DEV] Task-43 write tests - 38m
[DOC] Task-44 read BA documents - 32m
[COMM] Task-44 discuss with BA - 21m
[DEV] Task-44 Implement - 52m
```

Проект реализует консольную утилиту, которая на вход получает файл report.md, а на выходе отдает статистику по нему.

Пример:

```shell
$ work_report -m 5 -d 3 test/sample/report-1.md
Day: 3 mon
 - DEV: Review Pull Requests - 27m
 - COMM: Daily Meeting - 15m
 - DEV: Implement filters for Logstash - 39m
 - DEV: Implement filters for Logstash - 57m
 - OPS: Setup Elasticsearch - 39m
 - OPS: Setup Kibana - 17m
 - DEV: Learn how to search for logs in Kibana - 34m
 - DOC: Write a document about logs in ELK - 22m
   Total: 4h 10m
Month: May
 - COMM: 2h 58m
 - DEV: 7h 56m
 - OPS: 56m
 - DOC: 1h 39m
 - WS: 0
 - EDU: 0
   Total: 13h 29m, Days: 3, Avg: 4h 29m
```

Статистика включает:
- суммарное время за день;
- суммарное время за месяц;
- время по каждой категории за месяц;
- количество отработанных дней;
- среднее время за день.

## Формат файла

На верхнем уровне иерархии указаны месяцы (год не поддерживается, для этого можно просто иметь разные файлы):

```
# March
...
# April
...
```

Для каждого месяца указаны дни:

```
# April

## 15 thu
...
## 16 fri
...
```

Для каждого дня указаны задачи:

```
## 16 fri
[DEV] TASK-20 implementation - 17m
[COMM] Daily Meeting - 22m
[DEV] TASK-19 investigate bug - 43m
...
```

Задача представлена категорией, описанием и затраченым временем.

Категории не могут быть произвольными, они представлены фиксированным списком:
- COMM -- коммуникации, рабочее общение (митинги, почта, мессендеры и пр);
- DEV -- разработка и тестирование;
- OPS -- оперирование (стейджинг и прод) серверов;
- DOC -- документация (чтение и написание);
- WS -- workspace, настройка рабочего окружения;
- EDU -- обучения (себя и других).

Время представлено в часах и минутах: 43m, 1h 39m, 4h 29m. Других вариантов (секунды, дни и пр) нет.

## Использование скрипта

Тут все довольно просто:

```shell
$ work_report --help
USAGE:
    work_report [OPTIONS] <path/to/report.md>
OPTIONS:
    -m, --month <M>  Show report for month (int), current month by default
    -d, --day <D>    Show report for day (int), current day by default
    -v, --version    Show version
    -h, --help       Show this help message
```

Примеры:

```shell
$ work_report test/sample/report-1.md
$ work_report -m 5 test/sample/report-1.md
$ work_report -d 3 test/sample/report-1.md
$ work_report -m 5 -d 3 test/sample/report-1.md
$ work_report --month=5 --day=3 test/sample/report-1.md
$ work_report --version
$ work_report --help
```