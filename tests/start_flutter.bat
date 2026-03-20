@echo off
echo Nurai Flutter release build baslatiliyor...
echo.
echo [1] Release build aliniyor...
cd /d C:\Users\KULLANICI\Desktop\fizyoterapi\mobile
flutter build web --release --no-wasm-dry-run
echo.
echo [2] Statik sunucu port 8181'de baslatiliyor...
cd build\web
npx http-server -p 8181 --cors -c-1
