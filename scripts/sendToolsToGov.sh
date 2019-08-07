
function zipTools() {

  zip ~/tools.zip ~/tools
}

function sendToolsZipToDropBucket() {
  aws s3 cp ~/tools.zip s3://fcms-factory-drop-20180101/contents/tools.zip
}

zipTools
sendToolsZipToDropBucket
