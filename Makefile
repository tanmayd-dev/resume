# Resume build -- XeLaTeX
ENGINE  := xelatex
FLAGS   := -interaction=nonstopmode -halt-on-error
SRC     := main.tex
OUT     := resume.pdf
OUT_PUB := resume-public.pdf

.PHONY: all public watch open clean distclean

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
