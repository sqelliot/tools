
function zipTools() {

  zip -r  ~/tools.zip ~/tools
}

function sendToolsZipToDropBucket() {
  aws s3 cp ~/tools.zip s3://fcms-factory-drop-20180101/HM/tools.zip
}

zipTools
sendToolsZipToDropBucket
