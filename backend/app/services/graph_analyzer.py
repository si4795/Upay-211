import networkx as nx
from typing import Dict, List, Any

class GraphAnalyzer:
    def __init__(self):
        self.graph = nx.DiGraph()
        self._seed_default_graph()

    def _seed_default_graph(self):
        """
        Seeds transaction graph with standard transactions and an illustrative
        money mule structure: Source -> Multiple Intermediate Mules -> Aggregator Destination node.
        """
        # Normal flows
        normal_edges = [
            ("USER001", "USER102", 500.0),
            ("USER001", "USER245", 1450.0),
            ("USER002", "USER304", 1200.0),
            ("USER003", "USER102", 800.0),
        ]
        for u, v, amt in normal_edges:
            self.add_transaction(u, v, amt)

        # Money-Mule structure:
        # A -> B, C, D, E and B, C, D, E -> X (Syndicate aggregator)
        mule_sources = ["USER_MULE_A"]
        mule_hops = ["USER_MULE_B", "USER_MULE_C", "USER_MULE_D", "USER_MULE_E"]
        mule_target = "USER_SYNDICATE_X"

        for hop in mule_hops:
            self.add_transaction(mule_sources[0], hop, 25000.0)
            self.add_transaction(hop, mule_target, 24500.0)

    def add_transaction(self, sender: str, receiver: str, amount: float):
        if not self.graph.has_node(sender):
            self.graph.add_node(sender, type='sender')
        if not self.graph.has_node(receiver):
            self.graph.add_node(receiver, type='receiver')

        if self.graph.has_edge(sender, receiver):
            self.graph[sender][receiver]['weight'] += amount
            self.graph[sender][receiver]['count'] += 1
        else:
            self.graph.add_edge(sender, receiver, weight=amount, count=1)

    def analyze_network(self) -> Dict[str, Any]:
        """
        Calculates network centrality, identifies high connectivity nodes,
        circular loops, and flags potential money mule clusters.
        """
        in_degree = dict(self.graph.in_degree())
        out_degree = dict(self.graph.out_degree())
        betweenness = nx.betweenness_centrality(self.graph)

        # Identify potential money mule patterns
        # Node with high in-degree receiving from nodes that received from a common source
        suspicious_mule_nodes = []
        for node, in_deg in in_degree.items():
            if in_deg >= 3:
                suspicious_mule_nodes.append({
                    'node': node,
                    'in_degree': in_deg,
                    'pattern': 'Fan-In Aggregator (Potential Money-Mule Destination)',
                    'risk_level': 'HIGH',
                    'recommendation': 'Requires Investigation'
                })

        # Identify fan-out dispersers
        for node, out_deg in out_degree.items():
            if out_deg >= 4:
                suspicious_mule_nodes.append({
                    'node': node,
                    'out_degree': out_deg,
                    'pattern': 'Fan-Out Disperser (Rapid Smurfing Pattern)',
                    'risk_level': 'HIGH',
                    'recommendation': 'Requires Investigation'
                })

        # Circular flows (simple cycles)
        cycles = list(nx.simple_cycles(self.graph))

        # Nodes and edges for UI visualization
        nodes_data = []
        for n in self.graph.nodes():
            is_suspicious = any(m['node'] == n for m in suspicious_mule_nodes)
            nodes_data.append({
                'id': n,
                'in_degree': in_degree.get(n, 0),
                'out_degree': out_degree.get(n, 0),
                'betweenness': round(betweenness.get(n, 0.0), 3),
                'is_flagged': is_suspicious,
            })

        edges_data = []
        for u, v, d in self.graph.edges(data=True):
            edges_data.append({
                'source': u,
                'target': v,
                'amount': d.get('weight', 0.0),
                'count': d.get('count', 1),
            })

        return {
            'total_nodes': self.graph.number_of_nodes(),
            'total_edges': self.graph.number_of_edges(),
            'high_connectivity_accounts': sorted(
                [{'node': n, 'degree': d} for n, d in self.graph.degree()],
                key=lambda x: x['degree'],
                reverse=True
            )[:5],
            'suspicious_networks': suspicious_mule_nodes,
            'circular_transactions': cycles[:5],
            'nodes': nodes_data,
            'edges': edges_data,
        }
