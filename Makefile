build: ## Build all content, along with drafts without serving them.
	hugo --buildDrafts

serve: ## Build all content, along with drafts, and then serve them in the current session.
	hugo serve --disableFastRender --buildDrafts

clean: ## Clean out the public/* directory, removing all Hugo generated content.
	rm -rf public/*

gha: ## Clean the public directory, then build all content, along with drafts, using the Github Pages baseURL.
	rm -rf public/* && hugo --baseURL https://tmswfrk.github.io/nilpointerblog --buildDrafts

publish: clean ## Publish the site, removing the public/ content and rebuilding it. Then upload it to Azure using the provided sync script.
	hugo --baseURL https://www.nilpointer.blog --gc --minify --templateMetrics --templateMetricsHints
	./sync.sh && echo "Make sure to purge the CDN in the Azure Portal!"

update: ## Shortcut to checkout the main branch and update it. Used after a successful pull request and merge.
	git checkout main && git pull

.DEFAULT_GOAL := help

.PHONY: help

help: ## Shows this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
