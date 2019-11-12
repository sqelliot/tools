## Script to Test ICS instance services
## upload enriched equipment codes to both the dwn and val services
## Download codes.
## Test code with validation

S3=s3://fcms-factory-data-20180101/ics/EquipmentCodes-20180202-175400002-ics-enriched.ldjson

#VAL_PORT=8060
#DOW_PORT=8080
HOST="internal-fcms-cint-99-ics-dwn-000821152832.elb.cdc-west-2.devlnk.net"
CODE=ZGAHH


# Post
echo 'Post to ICS'
curl -v -X POST "http://${HOST}/data/update?equipmentCodeURI=${S3}"
curl -v -X POST "http://${HOST}/data/update?equipmentCodeURI=${S3}"
echo

# Download
echo 'Download from ICS'
curl -v -X GET "http://${HOST}/download?pageNum=1&pageSize=10"
echo

# Validate
echo 'Validate with ICS'
curl -v -X GET "http://${HOST}/validation?equipmentCode=${CODE}"
echo
