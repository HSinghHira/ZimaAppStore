init:
    git init && git add . && git commit -m "First" && git branch -M main && git remote add origin https://github.com/HSinghHira/ZimaAppStore.git && git push -u origin main
deploy:
    git add -A && git commit -m "Building" && git push
d:
    git add -A && git commit -m "Building" && git push