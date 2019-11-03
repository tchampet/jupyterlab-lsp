from .config import load_config_schema
from .utils import NodeModuleSpec


class YAMLLanguageServer(NodeModuleSpec):
    node_module = key = "yaml-language-server"
    script = ["bin", key]
    args = ["--stdio"]
    languages = ["yaml"]
    spec = dict(
        display_name=key,
        mime_types=["text/x-yaml", "text/yaml"],
        urls=dict(
            home="https://github.com/redhat-developer/{}".format(key),
            issues="https://github.com/redhat-developer/{}/issues".format(key),
        ),
        install=dict(
            npm="npm install {}".format(key),
            yarn="yarn add {}".format(key),
            jupyter="jupyter labextension link {}".format(key),
        ),
        config_schema=load_config_schema(key),
    )
