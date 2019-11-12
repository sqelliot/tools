## Script to Test ICS instance services
## upload enriched equipment codes to both the dwn and val services
## Download codes.
## Test code with validation

#S3=s3://fcms-factory-data-20180101/ics/EquipmentCodes-20180202-175400002-ics-enriched.ldjson
S3=s3://fcms-factory-data-20180101/ics/EquipmentCodes-20180202-175400002-ics-enriched-LIMITED-WithMIDBArray.ldjson

VAL_PORT=8060
DOW_PORT=8080
HOST=$1
CODE=ZGAHH


# Post
echo 'Post to ICS'
curl -vX POST "http://${HOST}:${VAL_PORT}/data/update?equipmentCodeURI=${S3}"
curl -vX POST "http://${HOST}:${DOW_PORT}/data/update?equipmentCodeURI=${S3}"
echo

# Download
echo 'Download from ICS'
curl -vX GET "http://${HOST}:${DOW_PORT}/download?pageNum=1&pageSize=10"
echo

# Validate
echo 'Validate with ICS'
curl -vX GET "http://${HOST}:${VAL_PORT}/validation?equipmentCode=${CODE}"
echo
