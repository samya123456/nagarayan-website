#!/usr/bin/env bash
# Deploy the Nagarayan Developers site to S3 + CloudFront (HTTPS) on nagarayan.com
# Prereqs: AWS CLI v2 configured (aws configure), domain nagarayan.com registered,
#          and a hosted zone for it in Route 53 (or DNS you can edit at your registrar).
set -euo pipefail

DOMAIN="nagarayan.com"
BUCKET="$DOMAIN"            # bucket name = domain
REGION="ap-south-1"         # Mumbai
SITE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "1) Create the bucket (private; CloudFront will read it)"
aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" 2>/dev/null || echo "   bucket exists, continuing"
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "2) Upload the site"
aws s3 cp "$SITE_DIR/index.html" "s3://$BUCKET/index.html" \
  --content-type "text/html; charset=utf-8" --cache-control "public, max-age=300"
aws s3 cp "$SITE_DIR/assets/" "s3://$BUCKET/assets/" --recursive --cache-control "public, max-age=604800"
aws s3 cp "$SITE_DIR/assets/sky.hdr" "s3://$BUCKET/assets/sky.hdr" --content-type "application/octet-stream" --cache-control "public, max-age=604800"

cat <<EOF

3) One-time setup in the AWS Console (about 20 minutes):
   a. Certificate Manager -> region US East (N. Virginia, us-east-1) ->
      Request public certificate for: $DOMAIN and www.$DOMAIN -> DNS validation ->
      "Create records in Route 53". Wait until status = Issued.
   b. CloudFront -> Create distribution:
        Origin: $BUCKET.s3.$REGION.amazonaws.com  (choose the bucket, NOT the website endpoint)
        Origin access: "Origin access control" -> create -> then "Copy policy" and paste it
                       into the S3 bucket's Bucket policy.
        Viewer protocol: Redirect HTTP to HTTPS
        Alternate domain names: $DOMAIN, www.$DOMAIN
        Custom SSL certificate: the one from step a
        Default root object: index.html
   c. Route 53 -> hosted zone $DOMAIN -> create two A records (Alias) -> CloudFront distribution:
        $DOMAIN  and  www.$DOMAIN

4) Later updates: edit index.html, run this script again, then invalidate the cache:
   aws cloudfront create-invalidation --distribution-id <YOUR_DIST_ID> --paths "/*"
EOF
