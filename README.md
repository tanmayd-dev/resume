# resume

Source for my resume — plain LaTeX, compiled with **XeLaTeX**.

📄 **[resume-public.pdf](resume-public.pdf)** — the public build (no phone number).

## Build

```sh
make           # -> resume.pdf          (submission build, includes phone number)
make public    # -> resume-public.pdf   # (safe to publish)
make clean     # remove LaTeX intermediates
```

Requires a TeX distribution with XeLaTeX (TeX Live). The only font used is
[Inter](https://rsms.me/inter/) plus `fontawesome5` for the contact icons.

## Layout

Single page, single column. Sections: Summary · Skills · Experience ·
Publication · Projects · Education · Additional.

The phone number is gated behind a `\PUBLICBUILD` flag so the public artifact
stays clean of scraping targets.
