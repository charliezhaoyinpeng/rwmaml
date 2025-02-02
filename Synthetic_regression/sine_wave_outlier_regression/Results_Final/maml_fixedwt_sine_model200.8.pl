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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_fixed_weight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_fixed_weight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2327165759136qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2327165760864qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2327165756544qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2327165761344q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2327165759328q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2327165755776q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2327165755776qX   2327165756544qX   2327165759136qX   2327165759328qX   2327165760864qX   2327165761344qe.       }IϿ@      �E<k��=�#
;��Ѻ��|����<��"=�vE�ge�Lh�=��=늕�ޮ��C�)��Q�.�ڽ�@�-F"<��B���/=�E=8�J��=l��������<:��=�?{�F��z�U�
`�
������ɽfа��$�=捰;y:�}z�����=�~�>G����>��k��8?�7�=�L� f�����>�J���^�,����^����=��D������=?LY=�����>?]=<X�*�?)�Y�5��H���v��_�<b̟�y�F���p�_��>��è�;�7�?�����_�>r����!�#���i����Q��?X����sǽ�,��%������#���"C�];׾���>bu�=:�>7�z��S>-O)?$��>�h4��5V?����0��s�����?���Z���;Y�V�>�0>�i������I�>���<�W�`?�:$>�5��%D3�ؠ7��N�e@��PѿU�DF�m��u��6��rՏ��B->IUX�X��������`���� �̳��z���K�?�1�����G���V>��0��n���󀿤B��j-��Qѿ��ˤ���#>5-� �q�T-������o?S��J��>���=Q�.�%��`Ծ9|"�G��᝘<��Ƚ��=~�C-<#N�=6�G���L�K>fv�*}b>V���;>�R.=ea>V�=&,=֧)�E
ѻ��v����ɑ�N3����>k�缈�->ں��?�4X��;�=�x��t��F�g=�.b?� Ϳ���=U�;������������ު��գ<�K���P>!d�?G��R�2��g��[/��>�/�풀�/eC��[i?\�8<��I������=�U��,۴�%���AP���q��.:�����o���a`�Еm�z���7�W�>�@O���"�N|?�X�caq��	>�J'>��8�#��b�s=w׃<���<VU=t����o���_��ws,>^E�w��<lG�hQ>(����b����*�<�!������'��7s�=[x����C���q�r,���=>�E>I�"�Pe�<��5=�N->����j 2�Z؊�\+g>Z�c��.���>�\>Z?�Y6��>S�>�A�N� �uyD>����78?^}��4��o��=B���ʽ�N=>0Խ��̾��=�g��)J�Q�>�s?쮭�!�I�B��>Te>#о�>��P3��J�=��ξc��?���>�TֿS]���t?F:п�$�R�v��-y�����i��<`��;!>>��0?0�=���9W>��q��~]=�|��$�2��i4�����!(m�H7ڽx���ѩ>?g�=�
���/ѾW"�ڬ ����>{Y)>��^��])��.��`��}����ن>��>=��?#���_���@s�]}>����+n��񥾺����?��� ���\��#�?�������H�͠�=s���T��2���(
�+��>mT7��[���a;��*>}@���쎾k"��hھ/�a��+
���������Z�k�E$��~����A�<Z�=��ؿ�_��<M>�B������:��� ���>B�>S>[<ʓ����<��=� =��9�y�i�9�<?���<��ֽ=( ��>"�,���=����d�2� �d%����N?�m�N J��-	?+��>6[��&�<8}�#�{>��S�J/�����$u=����ߎֿ���>�=.�3�k������>
��ΕM�p� �S �<�p�>�ɳ�L�^��uI?pN����*�"���;��?�*4���]�Z���ä>!>~ ��[�?/C�߀�1�)?�9��!T��V��3�wS	�I�U�<:��T�?���?)�!�KCl��x6?X��>�n><A�}�d�e=��iB����G=�~۽h罘�t�8;��K�'�g�<��=��!���ٌ��߽nc�=���y���b� �{�z7��C/= ��;z��d3��{������C�Tq�����������>����WH�:���7:�JJϽ�?2;ճV=x}�=��b�\�� >���蟽A@=��żǲ3��U�<�r�Y�=w�ª=��=
��P
�<t��<����E��s���q�=�	�p.��]`��&�޽�L�<h�1�0�r=g�ϽU� ͢=_ز<�;0���'��r�=���=�K��ս��=0ʻ<@�}<-6�>�=�Ir=��9�� t�3����F��bs��W"~��v�<��@�����N��ԇ�<�x�SX��_�=^�>�!�'��_%�w��J=��Y���=�*�=�ē=G�:��%
�<k�=�:Z�潞=�#1�  �=���=f�=��> C���j�޽�={��>��>,� >#0�\���$�ay�>.R�q���-��>���?"�V�Џ�&ͤ�r)�='.�>���F�m�E��t"��*5�c���{���`=�A���$����|D�>^ @��]���<?E'���$?��??�=�l��F�<A�轗�Q>%>_�?�O��3��:K���ۆ���^� �N?����̀��ِ��?�m���L�=*�>6?��_>f�7���;n�T�\ѓ>���_���et�R���;�l�T�+�>���?@�H?I���W�o� ��z�?3����>���=�6m��^���Ć=\�ֽ���?T���ps>�}��
<��ʽ3d8��;���������Wc�٪�>�Y��#ɽ�?�e��>�	���������@3�W�->���:���`�z��=tS1=m=:���?�t>M.�>�];���6�$�a�m|I��c=�� ?^� ��qF���7;���5	��o0�>��>d��=x3�����>��j�[��>;ޚ����>�$-?�R_�h��ԇ��䃽��?�H/=m�>l�)�����x>ۜ��W{?T��=n��>tt4=�H=`�>}S��y���63��>���=�5���-�G����1"=41=s#?k?L?->k�޽Բt>��P� .�>	4��؜�PԾU�>����J.Ͼ���&6�>�I?�;J=N#=���C޽OŁ=�Pp>�J��3gz�⃘��G��Ct޾���>4P�>�>�����5����8�M��>�!J���7>�&�2ۿ;�T����=�P#��%�?�RJ?����ξ�3��ԏ��YᾐQ#��N:���?�9G���{��;��Tӿ`.n��u�?�%��̛�3D�0zξ�a=��ﾡ	<����c��GH�ӑ!��!�>k����?�k�[��>�鳿��߼<Ƚ��=*ɽ&���h=z&����!��3�=u$���Fu�m���K��Γٽ/Ž���:�-�4cN=��ɽ�y� C�<C岽Fۻ;�b'��F= !�יQ��3���y�=��B=�.�<A
>e�>�����=�>�4���4��{�=�c����H�/�|�I<g	,�ƨ!���<7�=�����k��WýTo^��X۽b�ŽF�M==1U�/��a����A=t�}<�;���uӽ�{������<��?������vL>`�>>���Fb�� �~%	>�O�=�#���>�,�>p�<��BԽ�����7���*�sI��)j�<L�=P��<�ܮ��.a�,�>�����i����L>�� ��k�>sQԿ��#>�Y��C>�鞻X�|�wp�=���� �q�.�j��������>�T>���=��￼�/��\i=5r>�\\��߃�|޹>�7d?\��0�>�a�;��[=T�%>��*�RO��d�S��0�=�g&��@?�Z6��!��\�#�*��J���[���>>E����OT��/��n9����*�~
���2=�!k���G��O����X��s��O�>��T�۾�MB� ����y�,�c�ܪ%?�-&>����ӯ�~:>bM�>��J�:O�Ku�;t�x�w۽�ɧ?��]�!*��xg��ך�l���L�@�t��=nƮ��
��>�Ծ�tq���H��#>��ü��Y��ﶼ�F��,�D�پ-(�~R�=���Q᪾;3��Z1=u{F>�����̿��o=�l���-�<W����>*BW���Q�o���lJt=�'��i�?�T�>����N:��%���P�76�yJ�=���mS>]���{���Er`�(�\��_-�Td��g������S/�7Uh�L���F���=#?/�ڙ ��z��J�&��������N?�&�=������5ɽߒ;Mc�=9C�<�e
���=@��<�v�=���;��!���<@�<D(����R#�=���=KF��BLk�@��=n ��6���ڽFj�����7;���"�=��n=K�@='3K�h�=���>�T?L��@���_����=�rG�����nM����z�>��X�sP)�(����Fh�`<
=�>t;e$�>Hh��b�����B�'
��ʎ��6Ծt��>L��hFs�#�r�֪�&�A�ӡ���	�đ�=EE�=�
���k�w�.j����;d$�>u���n��E�Ͼ��z��I��:���'���6�>J�:��߾����ל�u:q��#Y��7�<C\>�=Bn�>#a>�ƽ{���Ž�ݨ��{ֽ�AŽ2�k=J/\?��Ͻ�^��C��6\+<s��;l��=WV��e=t�!��J��mSտݮ뽚cN�_Sս(�'�l���?,���?aq���8?K͝��f^;��	�a�f����;>���[�<���=!��l�<�Y
>)�����$>)��;�p�=�v���*��s�p��/='�j�]l>�!#>�a�<N퍾��ӽ�rɽ1ve?���<?%��D�'��5��<u�������u�b/��YV?{?��Fyg;�����3>A��< jD�j�V�=�T>�Ž����L���#�����j�=І���_�pX����q��, >"�<������O��]�>�-|�|����g��Xʽ�Q� ��>��>Q~ҽ2d��=<B�= ��>�z���(>�0�=��7�����넱���=��N�A���[�>���>���*�R�3@��<:Z�.s�?j�c��v��Z����̧�<[�<���=z8�����>�,��SZ��������YO>��S�p���V� �,��=��bL����:�e>j��z+�W�����<��>q򮿛�ÿq�D=��ſ�{�=d����h�=o��=Q�����*�u!>ظ2�9%3=*1ѽ�_t=�6�����=�0��:���P��E�F�� ��@E��M�<�����~���;�=��*��p�Ez��=q�
>p9�;Kh�=� ���� `�<��#��>{u���׼s���,��.���]=c��b���O�\?�'�V����A�=������^�=�*���h�����ؾ/����߾����Y/��+?�=��$��T`������lc�<��1�
ׇ���7�[���V>��/>G.��"d�uӋ�3d��'��1�����?�u�?}Qw>s�<��ƿ�������>+(#����=��ǽ0��>o���a�����Oh> M6�~ ?/{H���%��9:� VS>u.�=�B��).=��=0�=�K�>
)>�mT�>�p�>::7��]I�fD���A+����>�"�`A3=q��:�+>��-�$R>
����7z>�?#�XO,>�x�>����3�-��l�>`�?=����ۭ:>��ᾐ섿n� >F�����X������R>�ݛ�R�u�+MI���o����}=L� �ϊ�>��>�6R��ľ�,Q��n��{ܑ�Ȅ�=������b���Կ��7���ǿ��L�;�@����>A�W��g��^9�=o>�Ћ�����_|�=����;Gg�>]<3>d���fԕ�u��x�~<�哾�=It/�������a-��K��r�&�I�>�1�=�Nl��$�(���p�辺?�=����=����&��=W�D��0�=OB>���� ���K��J��]=1;k��졾���ɢ�>�5׾0�T�����Vs�n��ne���뾁�h�������� ��ͽ��>E�#M>aｱ�¾�^*�`�1��R���;?0�>涌>vV->p|R�[�5��(?H��Լ�=����v2?Aq�>&�??����m.>�Ű<�����H=��=e�ļ��C<��o�z�k�����I��#�<�.�v��w���N'�0�<�_1��M�<T��.>��t=a꽰�X�4�=R�ֽ-�V>Gܴ=��m3�=�؀��= /�=k�,=�\>o��=�51���=$`z�}0<x����Ͻ(       B�>��c���B�?� ��O�>
>���>�/���i=ӝE��D�P���}�>�+�;��=�!��*�5�,�B��wv�m+?&��>�r�>Kt�=_S��������"3'�$b1���>Q�L�=+v���|�>8om��t�8�F�]��=Oh=oN?(       ��2��  ��(b?����J��$���р>�2����>m�Ҿ�]��V?��0>��׼�۷�?�>�&`>8�"���(??#�?-��
J��c�s��]_>P�>/�A?�B�=~j?6�!��>�8'>��?E��o\��T?&o ?�>ۇ�o�<(       �\�F_?�C>@п9$��f��=̿ȸ[?��=!ڿ��?ix&���Ϳ�HԾq��=�$����2?�੾M�����ľ<T̿�Rۿ������>�	���ƿ���>HF0?m=V����=�H���C�yǄ��|���,q>zr�=w ^?�s�<�>�Y	�(       �p�=Ld.>�n�=7�?N�=��
>F�<�x9?��־P�=Թ=qu���{=#��t�t��7Ӿ��*�G�{>.y�ɜ���g�`fh�����+��]�=������>7v���>�!�>qUǾFs˽�8o>��_�3��>�!�=��/>'^!>r���!�