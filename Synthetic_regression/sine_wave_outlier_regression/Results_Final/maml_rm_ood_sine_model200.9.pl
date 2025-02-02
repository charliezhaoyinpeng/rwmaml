��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2002965317024qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2002965318272qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2002965318848qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2002965320672q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2002965321344q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2002965322016q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2002965317024qX   2002965318272qX   2002965318848qX   2002965320672qX   2002965321344qX   2002965322016qe.(       ���'s����=�@���澾\�+��>"��]����~��<{?J�վ�⾄|6?n�a���۾�g��ǚ��T0?fB-�Gn�f�ν O/��V��
��Q�����|S뽼�;��;?޶�>s"��C�.?[ރ=G�����-�����m?(       X� ��Đ=@&�>�	�>ܧ�^��ߋB='��>_���SC������C��O��y]���)$�y m��2>��P�(���n��h��?����7>�ޛ��&���־��>Xp�>�o�je|�=�>=���?m~>Y??��?��Ʊ=#!��C�Y�@       ~����7k�?�t�=��"��y����!��8�������=s���Hﾁ<$>RL4>�B��S�z���2>������,>�p���
ýE	׿SED�L�>0i�=f�f;>Y;k�I�v$��j�': ��tj����ֆ��uw��W�=�Y>�,�<jD�=P�`/�?����a�>��a���>�p��K׽|�վK�=�δ�Rw>�>��5����=���f�!��>bƁ>��ϽD���i�=^���Q�h�Cĸ>�	>���>y<�>��ؼ��=x�->v����fz?�ɽT�����KV�=�H?]a�=��_�6#�=�ݾe�Ⱦ����;�XT�<}s<��ž���/�=V��=��Ӿ��罾�	���=��<l���~�� �?;�z
�$_=�X��V�=�Y*��c����2F��/4�$��}���Spݽw�I��y>j�G��^K�{2��� ��|� �ʼJ~���e���"����`�8����=##佐~j�]��X�<@�r;��x=[��.�=��>n1����Ƽר��3ؽ˴�\���X�=��=@&=`	^=����*'�=PϼnV�=3'��`B���f�=�����Ͻj��pѼ1���q>QK=��ǽॳ=Ia/�����r���:ӽQt!��ʽ��R����<�_Ž�K¼�a�=>��=�(�Y���={�ͽ��E��`>����P��\S<��ܽ�c9���:�����?�|Lܽ$l���U��<�����A,���=�a�#²��r�\�ҽ��v=7i��Խ�=��G?q9� q?=� �\�;�旽�گ=F�w��sz��?rx�a������>O��X\�"ܸ=?z���~7�/i����J�Gh�>�e������J ��>3��,�d�>>L3�i.�>e6��0��?^>����)�������>������,>x~
=�?\Z�?����_K[�I����?!a>CA��b|j�[��<!��&����=aL��7r޽�^ݼ�����:k�W�� �=w%�A�X3U� ���pK�ԛ;�k2�0�V>q�S?}���>�>t�׿8b�<9�<K)S�k�����>M䨽���> ����b�t�;ƻ,�"ɖ>$�Ѽ�͊�R�Žĵ�=����)��>�m�=�==��="UW=���l�9���h��m<긞=�e>R��O#��&�<>�7Ǽ�嵼3��C��;��K<!�=<��=Tе�NJ�<��޽U����0W��1�|v=�"�����<0!���?Y�%>WNU�T�;�Jn=��=i���w���gB<Q_=�:?���f]o=~>��"�TE�<yhܾvG�=i �=�r��!«=MiI�ix���?a���=]L��C��=]Ѩ=D���W{�>��<>=Q?$��>�@Ͼ6`����9�E��=��Q���?>	�=�� �O�G=�'��=�=Uy<D����R[�~aj<*(�`�M>۳̽Cn�=r.p���=�v�;�&��y�Ƚ3	�=��=�E�=��L�o�X��=q�=���̊7�jf�����HNm=c�=�2�=C}��:Ža�5��|�x8�x4=�U���"!�2�=m���8���&�Psx���d|��P�Z<� �lc	���>�`==S>x��<��Q� .��H�����<�ښ��6�.��=X����6=NB�=ɩ>�X��Q���o=�)˽�j��+��LL����ػ�o�<  z��eE�  ����
�����)�N��*�=[�?B����<��2!b�B�%?B]�=	���E�Ou��j�����\���[��c���+�=�I �F�=��	��aӽ����M}�>B�����þ&}ܼ�!��$2��؂>��x�?'���=�1Ŀ��K���=Sா�\�=�����=`�� >��>��9>v���S��ט>�O��������<�q=��>AMH?��:��i׺�t�>�}$�l�è���>!��=��=�����<�D+=�$4�����?[� N�;]��>��3���>_wּ�]�?"zw>C��,4��@~��tx>7���b>f٩��N�ݚ?K���U�ܚ׻=7���(I���=�o	>�k��Z��@9>^g�>j,�>ǜ�[��>w~˾��f>dX�� �=��������ƽI9���~<֜ݽ!���������Ľ�����ʥ�;�|;�;������u>�T@���=�����Z�?[�>�9�<��">�J��D�6>B��S��>|�G�6��>ey޿_�/?C�<�k?Y��d�u>���<��V�Fj >%�m>�h&����=[���ɯ�%ͱ���>A�>��7>�O??�P�>�����򷽦M~�B>��XD�5����=����yv>�.��~��sn�=����7`Y>Dſ�)O>�9?j?���"��j?�ſ�ⴿ���>��>�~�<�N,=?��=��5>(C�>����"�ƿ)��>UL�b��3ϑ>"G�>x��>�t?a/���0�ܼ����Z>�bI����>h�ʾ��5��?9s7?�6�>J�{>�|ؽ>>�;��9<���d�i�Y��<�<�]^;J->��<M�Y�|��;�X>=�����VB<�*ѽ�� ���3ƨ:}u=�	T� m�=X�}�(�qսƆ�=��8�͂�=Dؽ�ҽ� �.B �]EｻxR=�ZB����<�*�=�+���ýNf�ؗT=H&�������|�2�'�C�ü]g'��½���=ߍ�P~�=p�I<�L��汓�̵"��������A��Ŷ�� @�7�0���ԟ��|��Q�i�1���+���yI�4���r�r��+6�d1�,Z7�h�O=��9䞾ڔw�f�)�Ad��%��c�A'��ǿ�Ҽy���ލ=��|��б<�\�kye��$�n@j�{���X)�:w��䡾%��D�c�������ѿ���;b�?D�޿Ž7¼�>f.����c>���=*���8"���>��w��6?�f`?�:q�M�E�@�<�Z�� bq=� ��O-��jʘ�4�A�����Ha��߿�蠽;��by��k �=6��=����]��h* �����Y�#>"�ӽ����g�?�vV=�b��]�l�N9$�*�9+�{Bս'����O}�8�.?���<r�>��>ƿ�]��h��:;f�ٽX���q:9>�Ћ�� >�Pb��R� ��;�/�=ů!�J� ����#?�^ک�[��Vмv}|=��V��i/=\7=s�ћ6=#��f��(�<t�x=�s��-���+н,�ȻxIG��"ֽ�6��J�h=��V�
���ũ�����m�x�o"�3��=�ʳ���#����=\YS��O-=Ok�����:�]^컹H�<���=�_��K��� ���=ߊ=��N�����Y���%
��30��,���3��#�;X#�5�V�w��}��`*i�.v��G���5���m~3��:<=��<t ��S�=�G���D8������۽��ʡ�=�`D<Ġ��Π�=���='�<�(���O�_�=	�Qw�+yP=w�4����f׾=�W==/�'��V�<�M4�xWp=�ʀ�K(�R��.�= �E��"ӽ�ƽ���=2B <�?���yP=�=����i=�T�=��y�r(��V'H=���=r�$>�����)�t̵>JB>��>��\���>�;=����>� y>�a ���>���Pjk�B�=Ї?�E=%3>���=U�>���>��>n���OZ�@�C=�d'�DO<~|9>�,�>�ƌ>�K2��K>uݽ�>[�=<�c>h6@>ɞ
�L������=���W;=��(��t�>�.N����>� >�=n�>��3A�;�<��u>㭕<O猿�`q>%�?l9��奄��}>��<)cJ>���>�n�=]��>�ꭾ�ÿ�>���>?0��)�>-����'�>ZQĽ���Y�R?�Cn?��>�,��	�
>K�>�?����/���8J����,�$m�#2+�l$¾Pަ>�[���Y��������O��J�ꢛ=�k�Y�h>:&�;{�l>�/�����`�>��N?#���,��������A?:p<܀=��%<�5"����=��!������h�<~�����������F���=|8��_Ža�=ok�K��<z��<�.��n�L�wd�=��x=hں��^�Uo�=��G�൨<-�����=XZ�=�/*�J�'�^Qx:Տ=~�K="���<R���lӽh�̽�#u��r�=����3��<��:����F�=.�=�tξ%q#�:k<�JU��b���
۽j@o��
��O:�Y���,�*�/(�^<���@���==3.>YQ�;H�=�y�9�꽗�7�����y���;��%n��O�����=�ws=�	b���V�����X{�繟�<�=�e��U���>��sA���+��;��x���T�js߾y����г��Ӿ@�ř��M��Əs�9ࢾ�2�M���->�c��?+�9=�0�¾~F��Ѵ��a��=�s�>��|�3�����;E��V�
?.e?."�M���������+�	���>��'�9�|<��Y�Ž!˩�n'��������t���?C����N�a�d>x�⛾�ӾM���>� �;b��m>?�/c�22L�����Ԣt�U��:�ݺ�����>��$>p��?���>I��=���寽�%��r����= �c<f$�=�9� }�<��>�X�<����Խ�,>4��>n
�����=�Z>�t�>Xls=��>-bz>�S�=�1�>��>��>w�k>�\r����>�卽���=�h>>��g>�������W��GYȽI��>G������Wd~�6ޕ>V�Ͻ9��=���<��S�vw?��6>1����G�������=�֛>H?��~0��'׏��Q?#�f���/�Y��>Rdp���~��kҾ%Wʼ�� >�͖�mAQ�a
?2��x7O�R���T�/��MY��Yu�i$-����>D=x�?kS�>����p���$���1�Z�m�v�E=�����ϻ�I�>߻��QDm�۟=��>�ㄾ�H�X<�>a���
R����=Rn���v%��匾8�!����]=>D���*�S�ؽ��? v���&�T�C��7�;�c>�{�Z�=�����%�>ݩ��+@ۼ�=J>�g=�>@���vy��d�>�O½�Z��m�Q�{,(�,���L�w����'ȿ��>`�k�аý����<�]�Al	��n����U�9� >O�t�콦G޽��=(���kq^?���=�}�B>^Q"�¢�=�ƫ���O����=��?ڙ�>Q֬><�K>`9ܼ ԍ�h6�<��>3�	��6}?[Y?�l�j��>�;�X>��>`	�>�H>*���Z�%��`>�3Z?���n��>��L>��ؾ�>Z�=hd?�2�Vd���g�>�L��}��>G��5�M=�y�=�Y1�N�3�0[>�P���x�=S�۾�0?��P|>���.�>�Ms>�C�<f�KE>x��;�>N������9���6)�]�����>����B�������'��B�E����E�F���:O��gM�=�X���ޛ?G)���4�	޾о1_H�A���T<�G4���T<~|�~6��t��>��:?ff��pp{�ڂF��b��+������>�۽�.��b>����9��� �<A��F��= ������0� =�ݾ� �<�� �|�L����=x|=.+�=pֵ=����|�=��F�h��#�ܽ��?=3w��U�K����=	���.���޽��z�G�:���XS���=��C�s�=������׽ �˼�L���p����K�>橽S����н`�=<(f/<+�^�Һ�=lP*����M;��\�f�=pE̽�ܼ��q��c��d�S�<�A;��r��P=���d������<x�<��h=���"�h�&8��X�dҳ�*�q�=a> �³G?�P=k�=�d>��Ͻ�����>O��>Q��������=K ?�¸����=��>��O��>%ݑ���>�<=�^�q�>R�=�rA>��<5�f>�㐾��ľiʙ�WfN����=N;���'��\����{�>Uyi���>�S6����<" ��C��c�>6�ݿ��v>�pD>��ɽ�ྐ�>B[��)���)�>Y�>�b��9�A>ռ;A�8>�w�>J�8>�濿�H>�h@��꓿�4x>'v�>��>G�?���3�$=������>J�	�d��>_�T�~�8��>t�ǽ�6?� �>(       s�Q�ܾ�cZ�H��7���q�R����'�:�j����0F�����ž����R�/���>���=�r��Ñ5�&P�=�n=��½󹺽D�ٽF3���A�빙?����J�Kz�>u`ҿp[��y�?W�=�j�>X���Nt�>?���=�>a�j�>(       ��>�x9?5ܒ��>�
K���>clT?�~�=G��>��>�S�==f����>(��=��8�n�6>晷=%$I=z�?N�Ǿo��=(b<G�8<QϾ��%�t�.�&U�= ߿�Id�?�� ?���>ʨ�>����m����>_�?�qd��5�;w��>X�;       ���