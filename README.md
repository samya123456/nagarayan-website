# Nagarayan Developers website

Static site for Nagarayan Developers / Nagarayan Estate (Srikol, Shyampur, Howrah, SH15).
Hosted on S3 + CloudFront at nagarayan.com and deployed by GitHub Actions on every push to `main`.

## Layout
- `site/index.html` – the whole page (3D tour, enquiry builder, roadmap, FAQ, contact)
- `site/assets/` – photo-scanned trees and shrubs (`.glb`) and the sky panorama (`sky.hdr`), Poly Haven CC0
- `brand/` – logo PNGs, hut → chala → tower animation (GIF / MP4)
- `infra/iam-deploy-policy.json` – least-privilege policy for the deploy IAM user
- `infra/manual_deploy.sh` – one-time bucket setup + manual upload (alternative to Actions)
- `.github/workflows/deploy.yml` – deploy workflow

## One-time AWS setup (domain registered at Namecheap)
1. **S3 bucket** `nagarayan.com` in `ap-south-1` (Mumbai), Block Public Access ON.
2. **Certificate (ACM)**: switch region to **us-east-1 (N. Virginia)** → Request public certificate for `nagarayan.com` and `www.nagarayan.com` → DNS validation.
   ACM shows two CNAME records. Add them in **Namecheap → Domain List → nagarayan.com → Advanced DNS → Add New Record → CNAME**:
   - Host: the part of the CNAME *name* before `.nagarayan.com` (e.g. `_3f2a...`)
   - Value: the CNAME *value* (`_xyz....acm-validations.aws.`)
   Wait until ACM status = **Issued** (5–30 min).
3. **CloudFront distribution**: origin = the S3 bucket (not the website endpoint), Origin access = **Origin access control** (copy the generated bucket policy into the bucket), default root object `index.html`, Redirect HTTP→HTTPS, alternate domain names `nagarayan.com` + `www.nagarayan.com`, custom SSL = the ACM certificate. Note the distribution domain, e.g. `d1abcd.cloudfront.net`.
4. **Point the domain at CloudFront in Namecheap (Advanced DNS)**: delete the default parking records, then add:
   | Type | Host | Value |
   |---|---|---|
   | ALIAS Record | `@` | `d1abcd.cloudfront.net` |
   | CNAME Record | `www` | `d1abcd.cloudfront.net` |
   (Alternative: create a Route 53 hosted zone and change Namecheap's nameservers to the four Route 53 ones; then use Route 53 alias A records instead.)
5. **IAM user** `nagarayan-deploy` with `infra/iam-deploy-policy.json`; create an access key.

## GitHub secrets (Settings → Secrets and variables → Actions)
| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | deploy user's key id |
| `AWS_SECRET_ACCESS_KEY` | deploy user's secret |
| `S3_BUCKET` | `nagarayan.com` |
| `CLOUDFRONT_DISTRIBUTION_ID` | e.g. `E123ABC...` |

Push to `main` (or run the workflow manually) to deploy.

Contact on the site: +91 90079 95554 · developersnagarayan@gmail.com
