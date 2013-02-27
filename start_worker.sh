erl -sname "greeting_worker_app@yanli-OptiPlex-780"   -i -pa `find . -type d -name include` -pa `find . -type d -name ebin`  -boot start_sasl -s  greeting_worker_app
