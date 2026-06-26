import json

def load(path):
    '''opens a file, parses the entire JSON into a Python dictionary, and returns it.'''
    with open(path) as f:
        return json.load(f)

def find_numbermax(data):
    '''loops through all nodes to collect the ones with find_number max to collect the following:
        'phase'  which phase this occurrence is from
        'id'  the node ID
        'type'  the type annotation — the key field for the bug
        'live'  whether the node is still active or was killed
        'inputs'  the IDs of nodes feeding into this one'''
    results = []
    for phase in data['phases']:
        phase_data = phase.get('data', {})
        if not isinstance(phase_data, dict):
            continue
        for node in phase_data.get('nodes', []):
            if isinstance(node, dict) and node.get('label') == 'NumberMax':
                results.append({
                    'phase': phase['name'],
                    'id': node.get('id'),
                    'type': node.get('type'),
                    'live': node.get('live'),
                    'inputs': node.get('inputs')
                })
    return results

def compare(buggy_path, passing_path):
    '''compared buggy and fixed lines for type matches'''
    buggy   = load(buggy_path)
    passing = load(passing_path)

    buggy_nodes   = find_numbermax(buggy)
    passing_nodes = find_numbermax(passing)

    buggy_by_phase   = {r['phase']: r for r in buggy_nodes}
    passing_by_phase = {r['phase']: r for r in passing_nodes}

    all_phases = list(buggy_by_phase.keys()) + [
        p for p in passing_by_phase.keys() if p not in buggy_by_phase
    ]

    print(f"{'Phase':<35} {'Buggy Type':<25} {'Passing Type':<25} {'Differs?'}")
    print("-" * 100)

    for phase in all_phases:
        b = buggy_by_phase.get(phase)
        p = passing_by_phase.get(phase)

        b_type  = b['type'] if b else 'not present'
        p_type  = p['type'] if p else 'not present'
        b_live  = b['live'] if b else '-'
        p_live  = p['live'] if p else '-'
        differs = '*** DIFFERS ***' if b_type != p_type else ''

        print(f"{phase:<35} {str(b_type):<25} {str(p_type):<25} {differs}")
        if b_live != p_live:
            print(f"  {'':35} live: {b_live:<20} live: {p_live:<20} *** LIVE DIFFERS ***")

compare('turbo-buggy-pretty.json', 'turbo-passing-pretty.json')
