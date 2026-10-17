# resume

Source for my resume — plain LaTeX, compiled with **XeLaTeX**.

📄 **[resume-public.pdf](resume-public.pdf)** — the public build (no phone number).

## Build

```sh
cp phone.tex.example phone.tex   # then put your real number in it (gitignored)
make           # -> resume.pdf          (submission build, includes phone number)
make public    # -> resume-public.pdf   # (safe to publish)
make clean     # remove LaTeX intermediates
```

Requires a TeX distribution with XeLaTeX (TeX Live). The only font used is
[Inter](https://rsms.me/inter/) plus `fontawesome5` for the contact icons.

## Layout

Single page, single column. Sections: Summary · Skills · Experience ·
Publication · Projects · Education · Additional.

The phone number is **not stored in this repository**. It lives in `phone.tex`,
which is gitignored — copy `phone.tex.example` to `phone.tex` and fill in a real
number. The submission build (`make`) includes it; the public build
(`make public`) omits it. So the source itself carries no scraping target, not
just the published PDF.
