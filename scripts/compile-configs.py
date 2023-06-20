import json
import re
import sys
from pathlib import Path
from typing import Dict

import yaml

GLOBAL_REFERENCE_START_TOKEN = "{{ ->"
GLOBAL_REFERENCE_END_TOKEN = " }}"
GLOBAL_REFERENCE_SEPARATOR_TOKEN = " | "


def _resolve_inline_references(
    lookup_key_dict: Dict, inline_references, value_as_string
):
    for reference in inline_references:
        global_reference = reference.replace(GLOBAL_REFERENCE_START_TOKEN, "").replace(
            GLOBAL_REFERENCE_END_TOKEN, ""
        )
        global_reference_key, *functions_to_apply = global_reference.split(
            GLOBAL_REFERENCE_SEPARATOR_TOKEN
        )
        value_key = lookup_key_dict[global_reference_key]
        if not isinstance(value_key, str):
            raise ValueError(
                "Dict and list values are not allowed in inline references."
            )
        if functions_to_apply:
            expression = '"' + value_key + '".' + ".".join(functions_to_apply)
            try:
                value_key = eval(expression)
            except Exception:
                raise ValueError(f"Could not evaluate expression: {expression}.")
        value_as_string = value_as_string.replace(reference, value_key)
    return value_as_string


def _resolve_global_references(config: Dict, lookup_key_dict: Dict) -> Dict:
    # regardless of whether a list or dict was passed as parameter, bring them into a common shape by building an
    # iterator that contains keys and values
    config_key_value_iterator = (
        config.items() if isinstance(config, dict) else enumerate(config)
    )

    for k, v in config_key_value_iterator:
        # if a list or dict is found, recurse one level deeper
        if isinstance(v, dict) or isinstance(v, list):
            config[k] = _resolve_global_references(v, lookup_key_dict)
        else:
            # if a global reference key is found, resolve it and update the config accordingly - else do nothing
            value_as_string = str(v)
            values = re.findall(
                GLOBAL_REFERENCE_START_TOKEN + r"[^}]*" + GLOBAL_REFERENCE_END_TOKEN,
                value_as_string,
            )
            if not values:  # if there are no reference keys found
                continue
            # if the value is reference key itself
            # this is different from inline values because it could be various data types(list, dicts)
            elif len(values) == 1 and len(values[0]) == len(value_as_string):
                global_reference_key = value_as_string.replace(
                    GLOBAL_REFERENCE_START_TOKEN, ""
                ).replace(GLOBAL_REFERENCE_END_TOKEN, "")
                try:
                    config[k] = lookup_key_dict[global_reference_key]
                except KeyError as key_error:
                    raise ValueError(
                        f"Reference cannot be resolved, because key {key_error} is missing in lookup_key_dict."
                    )
            else:  # if reference value is inline
                config[k] = _resolve_inline_references(
                    lookup_key_dict, values, value_as_string
                )
    return config


def read_yml_with_variables(path: Path, lookup_key_dict: Dict) -> dict:
    """Reads a content of yml file.
    Parameters
    ----------
    path : Path
        An absolute path to yml file

    Returns
    -------
    dict
        A mapping from variable names to their values.
    """
    if path.is_file():
        with path.open() as file:
            payload = yaml.safe_load(file)
            if payload:
                return _resolve_global_references(payload, lookup_key_dict)
    else:
        raise ValueError("Invalid file path provided")


if __name__ == "__main__":
    try:
        template_file_path = Path(sys.argv[1])
        lookup_key_dict = json.loads(sys.argv[2])
        output_file_path = Path(sys.argv[3])
        data = read_yml_with_variables(template_file_path, lookup_key_dict)
        with open(output_file_path, "w") as outfile:
            yaml.dump(data, outfile, default_flow_style=False)
    except IndexError:
        print(
            "you need to pass the path to the template file as first argument"
            " to this script and dict with values as the second one"
        )
