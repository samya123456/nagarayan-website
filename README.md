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

## One-time AWS setup
1. S3 bucket `nagarayan.com` in `ap-south-1`, Block Public Access ON (CloudFront reads it via Origin Access Control).
2. ACM certificate in `us-east-1` for `nagarayan.com` and `www.nagarayan.com`.
3. CloudFront distribution: origin = the bucket, OAC, default root object `index.html`, redirect HTTP→HTTPS, both domain names, the certificate.
4. Route 53 alias A records for `nagarayan.com` and `www` → the distribution.
5. IAM user `nagarayan-deploy` with `infra/iam-deploy-policy.json`; create an access key.

## GitHub secrets (Settings → Secrets and variables → Actions)
| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | deploy user's key id |
| `AWS_SECRET_ACCESS_KEY` | deploy user's secret |
| `S3_BUCKET` | `nagarayan.com` |
| `CLOUDFRONT_DISTRIBUTION_ID` | e.g. `E123ABC...` |

Push to `main` (or run the workflow manually) to deploy.

Contact on the site: +91 90079 95554 · developersnagarayan@gmail.com
