# resume

Source for my resume — plain LaTeX, compiled with **XeLaTeX**.

📄 **[resume-public.pdf](resume-public.pdf)** — the public build (no phone number).

## Build

```sh
cp phone.tex.example phone.tex   # then put your real number in it (gitignored)
make           # -> resume.pdf          (submission build, includes phone number)
make public    # -> resume-public.pdf   # (safe to publish)
make ci        # -> distclean + public, exactly what CI runs
make check-public  # -> build, stage into _site/, assert nothing private leaked
make clean     # remove LaTeX intermediates
```

Requires a TeX distribution with XeLaTeX (TeX Live). The only font used is
[Inter](https://rsms.me/inter/) plus `fontawesome5` for the contact icons. Both
ship with TeX Live (`texlive-fonts-extra` on Debian/Ubuntu); no system fonts are
required.

`make public` needs no `phone.tex`: the `\PUBLICBUILD` branch of `main.tex` never
reads it, so the public build works on a clean checkout.

## CI

`.github/workflows/build-and-deploy.yml` installs XeLaTeX + Inter/FontAwesome,
runs `make ci check-public` on every push/PR, uploads `resume-public.pdf` as a
build artifact, and deploys `_site/` to GitHub Pages from `main`.
`scripts/check-no-private.sh` fails the build if the artifact is missing, if
`phone.tex`/`resume.pdf` end up in the published directory, or if the public PDF
text (or the build log) contains the private phone number.

## Layout

Single page, single column. Sections: Summary · Skills · Experience ·
Publication · Projects · Education · Additional.

The phone number is **not stored in this repository**. It lives in `phone.tex`,
which is gitignored — copy `phone.tex.example` to `phone.tex` and fill in a real
number. The submission build (`make`) includes it; the public build
(`make public`) omits it. So the source itself carries no scraping target, not
just the published PDF.
