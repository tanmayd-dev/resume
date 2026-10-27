# Resume build -- XeLaTeX
ENGINE  := xelatex
FLAGS   := -interaction=nonstopmode -halt-on-error
SRC     := main.tex
OUT     := resume.pdf
OUT_PUB := resume-public.pdf

.PHONY: all public ci check-public watch open clean distclean

## make            -> resume.pdf (submission build, includes phone number)
all: $(OUT)

$(OUT): $(SRC)
	$(ENGINE) $(FLAGS) -jobname=resume $(SRC)
	$(ENGINE) $(FLAGS) -jobname=resume $(SRC)
	@echo "BUILT: $(OUT)"

## make public     -> resume-public.pdf (no phone number, for the public repo)
public: $(OUT_PUB)

$(OUT_PUB): $(SRC)
	$(ENGINE) $(FLAGS) -jobname=resume-public '\def\PUBLICBUILD{}\input{main.tex}'
	$(ENGINE) $(FLAGS) -jobname=resume-public '\def\PUBLICBUILD{}\input{main.tex}'
	@echo "BUILT: $(OUT_PUB)"

## make ci         -> clean-room public build, exactly what CI runs.
##                    Needs no phone.tex: the PUBLICBUILD branch never reads it.
ci: distclean
	@$(MAKE) public

## make check-public -> build, stage into _site/, and assert nothing private leaked
check-public: public
	@rm -rf _site && mkdir -p _site
	@cp $(OUT_PUB) _site/
	@if [ -f site/index.html ]; then cp site/index.html _site/; fi
	@scripts/check-no-private.sh _site

## make watch      -> rebuild on save (needs inotifywait, from inotify-tools)
watch: $(SRC)
	@while true; do inotifywait -q -e close_write $(SRC) && $(MAKE) all; done

## make open       -> open the submission PDF
open: $(OUT)
	@xdg-open $(OUT) >/dev/null 2>&1 &

## make clean      -> remove LaTeX intermediates
clean:
	@rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz
	@echo "cleaned intermediates"

## make distclean  -> clean + remove built PDFs
distclean: clean
	@rm -f $(OUT) $(OUT_PUB)
	@echo "removed PDFs"
