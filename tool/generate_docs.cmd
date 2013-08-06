Xcopy /E /Y /H "c:\Projects\mongo_dart_docs\.git" "git_backup\"
dartdoc --package-root=../packages --include-lib=mongo_dart,mongo_dart_query,bson --out=../../mongo_dart_docs ../lib/mongo_dart.dart
Xcopy /E /Y /H "git_backup" "c:\Projects\mongo_dart_docs\.git\"
rmdir /S /Q git_backup
