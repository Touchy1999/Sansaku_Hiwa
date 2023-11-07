# PIS_Project2
第２プロジェクト(地域発見アプリ)制作用リポジトリです。

2023/06/20:アプリ名を「散策秘話」としました。

## Backend

### Docker

`backend`フォルダ内で`docker compose build` で構築

`docker compose up`で立ち上げ

### Django

google drveにある`settings_local.py`を`settings.py`と同じフォルダに配置

`manage.py` がある`sansakuhiwa`フォルダ内で`python manage.py runserver 0.0.0.0:8000`で起動