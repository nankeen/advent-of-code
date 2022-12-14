use std::collections::VecDeque;

pub mod arena {
    /**
     * Implementation of an arena tree.
     */
    use super::*;
    use std::hash::Hash;

    pub struct ArenaTree<T> {
        nodes: Vec<Node<T>>,
    }

    #[derive(Debug)]
    pub struct Node<T> {
        pub id: NodeId,
        pub data: T,
        parent: Option<NodeId>,
        children: Vec<NodeId>,
    }

    #[derive(Clone, Copy, Debug, Hash, PartialEq, Eq)]
    pub struct NodeId(pub usize);

    impl<T> ArenaTree<T> {
        pub fn new() -> Self {
            Self { nodes: Vec::new() }
        }

        pub fn new_node(&mut self, data: T, parent: Option<NodeId>) -> NodeId {
            let idx = NodeId(self.nodes.len());
            self.nodes.push(Node {
                id: idx,
                children: Vec::new(),
                data,
                parent,
            });

            idx
        }

        pub fn add_child(&mut self, node: NodeId, data: T) -> NodeId {
            let child_node = self.new_node(data, Some(node));
            self.nodes[node.0].children.push(child_node);
            child_node
        }

        pub fn get_node(&self, node: NodeId) -> &Node<T> {
            &self.nodes[node.0]
        }

        pub fn get_node_mut(&mut self, node: NodeId) -> &mut Node<T> {
            &mut self.nodes[node.0]
        }

        pub fn parent(&self, node: NodeId) -> Option<&Node<T>> {
            self.get_node(node)
                .parent
                .map(|parent| self.get_node(parent))
        }
    }

    impl<T> Tree for ArenaTree<T> {
        type Node = Node<T>;

        fn children(&self, node: &Self::Node) -> NodeChildIterator<'_, Self>
        where
            Self: Sized,
        {
            NodeChildIterator {
                iter: node.children.iter().map(|idx| &self.nodes[idx.0]).collect(),
            }
        }
    }
}

pub struct NodeChildIterator<'a, T: Tree + ?Sized> {
    iter: VecDeque<&'a T::Node>,
}

impl<'a, T: Tree> Iterator for NodeChildIterator<'a, T> {
    type Item = &'a T::Node;

    fn next(&mut self) -> Option<Self::Item> {
        self.iter.pop_front()
    }
}

pub trait Tree {
    type Node;

    fn children(&self, node: &Self::Node) -> NodeChildIterator<'_, Self>;

    fn preorder<'a>(&'a self, node: &'a Self::Node) -> PreorderIterator<'a, Self> {
        let stack = vec![node];
        PreorderIterator { tree: self, stack }
    }

    fn postorder<'a>(&'a self, node: &'a Self::Node) -> PostorderIterator<'a, Self> {
        let stack = Vec::new();
        PostorderIterator {
            tree: self,
            stack,
            cur_node: Some(node),
            cur_idx: 0,
        }
    }
}

pub struct PostorderIterator<'a, T: Tree + ?Sized> {
    tree: &'a T,
    stack: Vec<(&'a T::Node, usize)>,
    cur_node: Option<&'a T::Node>,
    cur_idx: usize,
}

impl<'a, T: Tree> Iterator for PostorderIterator<'a, T> {
    type Item = &'a T::Node;

    fn next(&mut self) -> Option<Self::Item> {
        while !self.stack.is_empty() || self.cur_node.is_some() {
            if let Some(cur_node) = self.cur_node {
                self.stack.push((cur_node, self.cur_idx));
                self.cur_idx = 0;

                // Continue on left node
                self.cur_node = self.tree.children(cur_node).next();
            } else if let Some((peek_node, peek_idx)) = self.stack.pop() {
                // If top of stack is the last child of its parent then pop
                if let Some((parent, _)) = self.stack.last() {
                    if self.tree.children(parent).count() - 1 == peek_idx {
                        return Some(peek_node);
                    }

                    // If top of stack is not the last child of its parent then move to the next
                    // sibling
                    self.cur_idx = peek_idx + 1;
                    self.cur_node = self.tree.children(parent).nth(self.cur_idx);
                    return Some(peek_node);
                }
            }
        }

        None
    }
}

pub struct PreorderIterator<'a, T: Tree + ?Sized> {
    tree: &'a T,
    stack: Vec<&'a T::Node>,
}

impl<'a, T: Tree> Iterator for PreorderIterator<'a, T> {
    type Item = &'a T::Node;

    fn next(&mut self) -> Option<Self::Item> {
        let node = self.stack.pop()?;
        self.tree
            .children(node)
            .for_each(|child| self.stack.push(child));
        Some(node)
    }
}
