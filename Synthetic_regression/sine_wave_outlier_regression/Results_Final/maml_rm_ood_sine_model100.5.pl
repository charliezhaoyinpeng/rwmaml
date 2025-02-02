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
qBX   2170595027856qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2170595028432qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2170595028528qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2170595027952q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2170595028048q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2170595028816q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2170595027856qX   2170595027952qX   2170595028048qX   2170595028432qX   2170595028528qX   2170595028816qe.(       1����'�(�3��J=�c�>��4?���(��<����U��Du=�.����<d';"�ؾ�@׾b�+���ɾx8�X{V?����:�=�z#?�6����0���!MĽ�׆={��>������Q�&�Ԝ��A���L6?�7?��ٽ+���S�.����(       N�i?("�������>����}ý1-��3G?������>��ȿ{����E�;�>�D�>�1D�C�5��c?�/���? �>�g���"��Ԛ>mWJ���i?DzU?�YG�:
���"������U�gP����8�۾�-���[E�rI�>!l����(       ������k��6����ϒ�=u�8�gM	�
5	���=?�K�>C�@��0?�Ė?`�,?s2�>A���s����k?�l���T
?h��� ��>�R���*?���<_��#�>c!>�/T?��?��
=�M?<�+�;���>8Go=F�]A�����(       5b=�q���Q�=X��T��>Ր)�D!9>���\�d��_��=y��:?0�>�Pj�x���QҎ��֒�V��|���l>< >*u����>e���ӿ���y� >4�=��=�|�=��>Y�sNܿ�d���#��V�>�J������@      0&x?�=�W���x*�th==�,�>q�.�]r��A����/�㪽��f���VԚ?�?�>��S���@�憙�'��@�?UЈ>_��fF���{��ӧ��l��2�<��>��>���=�ʰ���>[��z�I_ƿ�O>�%9��ld�VM
���&���m�ԛD=D���/�TxC��(>!�ֿI��ɤ�<1�޿�߁>��>v,����oX7=��b=��8d���=��H���pHȽ���>�3�><��(�=F�׿p	Ǿ�y�^�G>#:���9�=c���p�	��w�=��>U�N��fо���[��>W��䫾 �J<�];�TԖ>4[*�>R=�B
��4j=�F����=�4?�$�>�]3�GC�<��&>3����G"><bҾ\�2���v���B�>���m`�=	�����.v��B���C�"R=+ҍ��6>gO���7�&H�&��o��3�|+о���c�ڿ�S�#"�==k�>����K轒3ܽ��"�D�j�`��g��>��R>�Q���T0��=����m=Aό��˚�wN&>r,=�Խ��P=y��DL�<ҭ=�ks��Wk���������B�)��+�H��@؃��~�<���=�
ϽF`���̽�U�=�Q{�����[�>+<�z��4�=B >':۽�=JE?!�>��1��Om����>>n�?^G�4���?�z	�y���z�f?�]�>�X7�9�Ž�����.��~��6>xh+?���H6��(D=��>��n���@�}�̿k�[����=૪<`�"��=���wʽʻĽ���=Y> ��=ڇ�����=R�6�o��<�R���d��= 1��kݽ�<T=�L�G����=<ٽJߣ=�	��j�b�I�L���R��>��9=*����!K����0�<�n���ͽ�?B=B�>����Yb�=�>�I6�l=`��[�RCA�#5�=o�Z��=�q>���W���P|?~�F���w�0E==��>}�%�_�<޾{�/���ݜ�lI�>�0>.�
>�Dӽ' ��!Y��lƿp�����8�f���~��핾�����g��r�`9���^��>..i�h=��f��\�<�{�>��n�۽p݂��\��)���U<��>%~k?�R��0��<�2��������<�z�>�O��>SP۽teN�^�=�m>.U�=��� X��O彘�ۿ+lP�	rp� �3<��[<z@W�1xĿ �~<H���^�t�^����#� �|���7�D�=�N��e����t='��!������1�?E̡>Д=yO��T_�qG��������/K��j=�󋽶�W?\�����־+YA>[�X�����S����Y��G#�z��Y�,�Sj?���㉿��=�@�þ�+���I�<�ҧ��dI<˕��kq�
�޾Qُ>�+���
>Xr�P������I�?���b�6_x���c��OM������K���:>I_����m���8?K.M�rW1�w����� �Oe���˿.���b>�� �&�ؾ�}��Nɾ1�Y�K�F�#�W���-�æ� �q����=�+�:�}�>��>pڙ�#�=��>��D�:��%d���1�=ɹ?'��c����B��|g"�����"�>�n@+��>~ۨ>z�:>g�����<����8�����m�>�������~~��� ̽�֊�U��>�}?Mߺ�d���2�\���)?��>�K޾��sG�^!L?�k�S2�>�KJ��E<>�Wؾ����%?�X�>���|����W>+˫�A�=P�������)�_�� ��<uy�<�[,>ұ���4���S�>4Η�Jp���;%=�=T�`��;�]�~/Y�����%�>ai�=�J��KA��>�f\�*�ڽ(�2>�CS>?����e�R��9�>�Q<�1ڼ�ƿ؀o��o�?�'=�G��dT�9�#��9=�>UV�?Y�>s9����HýcG�8��ym��Q?�㾦��c�;��r:�>�����j=��<W�=�J��+���E�=��e��^>~��n���������t<��g���b��|ۿ8K�?�P?N�5�Gma�
8��CL��}�ž�������Ӹ;><A���?��ۿ�:�pVҾ�9�=�S�=����+���z�
y)>
1W��Df�
�S��-��^�������/	�@_�<���`r����:�H>(D����=wW7�~��=_%���?;�'?`>�%O�������_�i�(��˷��C�=�$��w�P�ʦ?Z��~�ة<AV���)���D�����살�W�
y�/ʮ�gD��r"�ʹ����禛�g�8�������>��=i�W��{������J\Ͼ�ᴽ����5;�!!��V?fN\>	��<�*#=	��
b��$y����1�5���Ş�N��<�1z>�J��I�}�2iʺ��7�r_���l��Zѓ����=P��<�����н�܆?�q�:��V�	������ ��2z=*���Xm�z*��=�n>�U�SH7�)W>����g;�/���?��?@pԾ���Uׂ��V��땔�;f;��ľ�&H��=���>
�s��:��9C�aJ��'�-�]u���|<��7�=�R�:�2�*M���n���ξ}��C��$zy��#.����=H�X��<B�a=��>�۾a,e< �Ļ�H��/^��pֻ�������>��%��S���� ���V�g��yz��ǀ?�ػ=F��=Vv*�tEʼe���=BX�|��=u�K=����߅�WL}��G3��Wo� �B#Z��=�D���3��%!{���p��<T�<{8	>>�>�~>����(�>�k>�k�>u�'>j�>I4���?B^/>�8F>��>���>ǯ>�^r=�?�=Z<L9>��A�2�>���>Hw�=�n�<��=��>Q^=:��FoC>���>f�=��s�t�=���>���>�t2�([��K�>>�«�c�R>�?����;=k�x����=�Dɾ�3�=V��=��������
z>�z>��^�Z>S�Ӿ�"n>}H?Է >d/⽺��@&�PO��V!�>��r�寽�V�=��g>��Ͼ���>ʄ�����=�3?T�>9���
�s̆>������Z>4J`=2ͬ�Ax�̈́t>!�h���<��;�ْE�8�5��?\�q=C���f��u�����<׏�����E�=g`��\+��q&?����nj������5e���Y��jo<�k>�]�=���9g���B��^T�	 ���ޟ�����xr�p�%= >�NU��6��Vg��,�=�����=��ٽ���x�>$��j���){>��>?�+�膼;q�|%>lR>�U��Gh�=J3?hH�=�7|�^��=_d��#�'����>ϘA= ��>�/þQQ?V�>z԰>L+�����������w����[>�<C=!>-i�>n�6����>U >l	�=�p>��/>S���t��Q��3�!>�E��I>�	1<�_�����Ux>6�r��ց>�F7=:�N>o��=?��?�q?�ܫ�y]I���l>��)>�?) 꿙I�=V=�>�_�>Yn>о� �=e%�x��<KB�<6��>�7`=b����F<nW�2B>���;t�W>���>봯���t�2�%�j�}���l<�������Ǖ�=���=���kY���a]��b��8�<�V ���r�i	��k�ǿ����^�����4��V��q-<�*���(>�>�*g�>�=�羏�\?�SU>,���e˽ ���x��X���D&�;Qb�H\s>R�澩\��N�e�>�vR�>�=>��^Z{��a]??�A[�`�+�7.��ԫ>�S>)�l>^�>_�<�]�hW��=2<�1�>| ���s?����,�����>K����z?[�=���,ި��o<������>�ɖ>ڀ俻����X?W��>�LD�rd�f'
��[e���>'�>�O8��h�=�m�Zž���>���>HbI?8T�?LJ�=<u_��t�>�;�_!��޿�7?�	��NU�ެc��Ed��3�:�� �;��}�!^Q>?���Ft=��ӽA�Kͮ=����V9>_6 ?:R��tL&�ϴ><|��8��D�[�_��2��=��꼰zQ�*<�������*'�;����xq�x��CR�n\�y�>�þ�h쾔=��Pt�<l�ٽ�>�N��=�6? �`���S=c.V���}%��k���2�=m��=]���u��ctR�N���9�T�t�>���>W֠>=" �����0>�Xb���V��O>�A`< ��;�Y0��5����?�>�.Ǿ�4Q�&"�V���#p�>^��>�C�>?�Y> T��EUE�A���r�`?�Լ1F���N�K���0�m���������]z�V��B?'X}�u�!�&����
�&��$<Po%������7R�?NRX�=̷��JǾn������E���u��?�. ?u<��D���G?��Y���߿*bh�V~L���1?�7�=DӾ�9�����Ҩ�l~�=�o��� �=;9��ؾ���>���?�u�>���>��?Rڜ�����!���H��p:��qD�e�a�f>nT����?�D��>sU�����0��1�ʾ�������>_AE�Y޿S����.�T�A2�j8�@C��N�=wʮ���ٶ!�˵����>1ᒿ��m=�"���?ڿ
F�>�?d��W��^;>�>��x��g/�Ү��
��|��:�>��C?	�~>�8��:�<�sܿ]�V>���č=:&���4�=<uѾ�´�͗k�:��P����ǭ�9Α?@�V<Y*ξ;��6r̽԰�>�ʘ��~ٿ�e�=�X�=T��=
?v_n�fSE>�)2?�/�>Fn6<�f�􋾙�>��=�A}��7�>A7��^��>�k����#>�@'��Ǖ>@08>�۬�|�I?�)�>,�8���<>O�O^M�π�g#���Ϟ�r�U�����c�<8��<�7Q�M������$>�s=�> v�>�*�=E�m��A1�i�*��1���k>��>+=D>�F<�{��<28��%�½!����PO>���>��=���>��:�j��?�"7�����@��bҼ`MP������Pq�r��>3�>}9=�������	>W	��.���\=��I�@ql<dԀ��i�=��=P�\<X�ü�:伒j.�e�>�t\���zړ���R=c*��>���TGH�}]>b���g����=�b�<�)�=/خ�����D~s��v��pe�<���<����Uܽo>����0j]���K�h�=':ἑ�E��N����v��������v ��@�P����پ��$�4�üء�=���>���=��{������%>
���T����l>�J��HI����=�i��+0?�ӌ�u*���'���M����;�e���>=�=���=c>ڋ־���= -��L�9�
6r>k6�>E���ߪ=P��<�TY�j��=6o�j�����>�3�����;I۽oKN�φ��%o?��q=�Ӑ>�ӓ> �ƽ
�&�A�=�&w���#>%��ܱ�>�U��@0�����k��:���=fJ�>6?ܠ�.�V�.-;�b�=���=�^e��v#��<k�L@����� ��=ذ�@=v;�e��>Kz���-=�����*�ܾt����=�-���q������.k���V��:���H���[n=�Z@��Qo��
��P�����pc?=f��uN(���E�~������:e�>��>&È�p%+����>x�<#-��ƽ�U��|���v� �-^��y������>�*�m��?�>�b�>X�[��(��`��" �=��>����e"k�j>:d����v��*	�V����׾�?�x;'>qYl���>���}�=�%�lt�>�di���&�[�����5z	�QZ*�h�漐�(��}���.< r���Ř=��-����@BG=��8<�x⼠�|<e�	>���� ���>`r�<ww�Op���Z7�ˡ�=������>�3;*.B�F�ི����\�=�B��#�� ]�<�[v�;�:W����xc]��(�=�E&?=-F����=ecG�+F,?�ڐ����P�＠nP<Q����B�=_	?55q?��0=�����=GTp��LZ=�T0�J	Y����^���嶾��=Ӛ?��j��B��<�|���`�]����	>E�ӽ��r���>�����'� C��E���0j�       ���