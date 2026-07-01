# Food Ordering Platform Architecture

Тестовый шаблон проектной работы по микросервисной архитектуре.

Проект показывает, как совместить:

- Structurizr DSL как источник архитектурной модели;
- C4-диаграммы уровней System Context, Container и Component;
- Markdown/MkDocs-документацию;
- ADR-файлы с архитектурными решениями;
- GitHub Pages как публичную витрину проекта.

## Быстрый старт

```bash
pip install mkdocs mkdocs-material
mkdocs serve
```

После запуска сайт будет доступен локально по адресу:

```text
http://127.0.0.1:8000/
```

## Проверка Structurizr DSL

```bash
docker run --rm \
  -v "$PWD:/usr/local/structurizr" \
  structurizr/structurizr:latest \
  validate \
  -workspace /usr/local/structurizr/architecture/workspace.dsl
```

## Экспорт интерактивных диаграмм

```bash
rm -rf docs/structurizr
mkdir -p docs/structurizr

docker run --rm \
  -v "$PWD:/usr/local/structurizr" \
  structurizr/structurizr:latest \
  export \
  -workspace /usr/local/structurizr/architecture/workspace.dsl \
  -format static \
  -output /usr/local/structurizr/docs/structurizr
```

После экспорта интерактивный Structurizr viewer будет встроен в страницы Markdown-сайта через `iframe`.

## Основная идея

Markdown-сайт является основным способом презентации проектной работы. Structurizr используется как интерактивный просмотрщик архитектурной модели внутри сайта.
