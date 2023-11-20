# a space-separated list of directories to check
src_dirs = src
test_dirs = tests
all_dirs = $(src_dirs) $(test_dirs)
githooks_dir = .githooks

help:
	@echo "format - format Python code with isort/Black"
	@echo "lint - check style with pylint"
	@echo "mypy - run the static type checker"
	@echo "check - run all static checks and analyzers"
	@echo "commitlint - run the git hooks"
	@echo "pytest - run the tests and measure the code coverage"
	@echo "test - run the code formatter, linter, type checker, tests and coverage"
	@echo "ci-test - run the Continuous Integration (CI) pipeline (check-only)"
	@echo "clean-pyc - remove Python file artifacts"
	@echo "clean-test - remove test and coverage artifacts"

gitsetup:
	git config core.hooksPath $(githooks_dir)

format:
	poetry run isort --extend-skip-glob "**/runtime" $(all_dirs)
	poetry run black --extend-exclude ".*/runtime/.*" $(all_dirs)

lint:
	mkdir -p reports
	poetry run pylint --ignore runtime $(all_dirs)

flake8:
	poetry run flake8 --extend-exclude '**/runtime/**' $(all_dirs)

mypy:
	poetry run mypy --exclude runtime $(src_dirs)

check-isort:
	poetry run isort --extend-skip-glob "**/runtime" --check $(all_dirs)

check-black:
	poetry run black --extend-exclude ".*/runtime/.*" --check $(all_dirs)

check: lint mypy flake8 check-isort check-black

commitlint:
	bash $(githooks_dir)/pre-push
	poetry run python $(githooks_dir)/commit-msg

pytest:
	PYTHONPATH=src poetry run pytest --ignore-glob **/runtime $(all_dirs)

test: format lint mypy pytest

ci-test: check
	make pytest

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +
	find . -name '.pytest_cache' -exec rm -fr {} +
	find . -name '.mypy_cache' -exec rm -fr {} +

clean-test:
	rm -f .coverage
	rm -f coverage.xml
	rm -fr reports/
	rm -fr htmlcov
