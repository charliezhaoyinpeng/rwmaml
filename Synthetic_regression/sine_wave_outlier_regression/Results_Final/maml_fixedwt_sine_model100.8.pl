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
qBX   2171084736208qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2171084739472qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2171084737648qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2171084735440q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2171084739568q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2171084739376q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2171084735440qX   2171084736208qX   2171084737648qX   2171084739376qX   2171084739472qX   2171084739568qe.(       b���O��>�1^���? �L���>�-Խ�"4�Ap`�V�?S�>�\;��(=��޽*�ؾ#>��>r��<7���r�Hx>���͌�ո��;��ξ�`#���u����ߏ��J����>�S/��g̾o�>]�A��C?f�<��+?�aT�(       U�>��#�׍5�rM��
?
>G�>5Z�� >>�;D��f���7��>�c�z[>�x�d���w)���7��q�<]�3?B�?�w�>_>ٽ5Hؾ{�ܾ�E�="������>D6H�����,��Ź>]�꽠���Z�,�=S��=��O?@       �v=�%߽~1׽l}D>8S����<��"=L���u����=�½�ޮ���0ʽ!��ӽ\�x��E�	6>��Y��E=8����=��v��� ?F �=��>�գZ��콂	R�{l>u=X����==}��_ˑ�z7�<Բ��4�&�D"ս���=^8<�	��R�IS�<�1�=�7�=x��n,�="�!>#K#��T�Ҫe�[���ؓv�<5�=%6���?�����ѡ��v�����:��M��^���`�>����?��������W��腾�VȽ�N�Z7���R���I�5@0?�o�>��"?���r�����=�Ƈ=��q��=�,�!1H���2�����(��E�>m�<��>=վ=�!_<C̜=���+�=�[���>�4�<�M"��0���u���
=�q=�6=�_V�h=(>ؽ2姽G����q�=b�z�Y���5c�nf���9�?����$�6;%����[�e��Y��u����>�+J[> (�<�H]��s��Pњ�����<lKq�7兽���>�4!��"H�_b���ȾI� N-��饿�.;>+��=�5+>���g���=�5b��O�;"(=?�F���0��8�����>D?���>��5�&t��IV�^����a:\��=��=#w�T}?�^ʾa�=�&�<���=�J�_��=�����E=n�p>����g �<�&?�7���2����&齳Z�x�?���>^V�p��7����u$��c���U>F�@��Q ����2(?�0�$����	v��;ǿ.9ǾL,�޶˽�K����߾���>�P���o������!�C�#��d���������cH�>���6�^A}��¾|�%lf�O���#�=N9&�8�|>��
J��a�ݩٽ���/�\��������J����7=�?��>^��F�=ӝ?g��H�k�ħ_=���<�׶������ܖ��9۾�fG�zN\��?��S��(>����p��������Ͼ��ȿa�/�ݣ�=�)����>���Xj�6jʿ�Pܾd� ���G>����	S�������lW=�
1?�J��hڽ��g?8?g��=��f=�s�=Z��=T�nr�S�>�?�=����r��wV��r�0��ֽ(v����ѻj_x=`:~���̻t�归1>*e�<?�s��5�<�,�=�};���կ<8��c{z=W1���?��w�="E=��r�~�7�_85=J��<����^T�����<c`�A#�<�A޾��������-�=`��;��?��}��NA>����}������7?VS.����v�d<9!>?*�oo�=1?Ǎ�>W�>�M�:���Gk=ܣ�<�J4?&� ����q�
��㽘���\�=�[�<[�⾚_��Q�Z�>d�>Υ?�c >��ƿ�4�h>���q�=� ��0]_�Q �?T
��ǒ��-����Ƚ5;l>/@��,��=������^��N�i��"��7g�>�&2>a
	>E��N�1�]�R,����)_�l�>>�eM�W���R,���M><&��}���>�J�ڀd���C>�����-? 0=���Ծ��<I�뽓2�>`p�����=�M ?wi���=_��z��D�<�x����%�V����0�d%��>��b1�>{'ܿ�ݾ�ד���>&+-���$�(��X��=|:����ž�?�Z-�!�2�Ӻ�U>	���ս׆�=��<����S�e�J�=p� �^�F<L�>cv���վ�0��zu��>�=�>��.k����$]��3R��뉾�����X>M�n=}F��'�^>o设DB�ɪ龽
,��0��ܼ�n������*�ξsZ����>�������?ʀ?e"=���=���9����SI<��G=�JO��d��[j��8;��]���g�<���@.�%�@��ٌ�;���nc�=����d��(ҽ� ���H���� ��;z��fҽ��_Ⱦ���ح�Tq�������Ƚ����}j�]_R������t �B���n����w=ב�=���fƼ� >��ս�S����E=]p+��+����<�>ü�z6=���/�=*=[��P
�<لG���U��E������U�=�	�����9Ü�Ȱ̽��<�b7�0�r=����p"��=�C�<�(�B� �B��=���=q�	��%�����½O��>'P�>�=��ؾ�iL?�����_��}U�7��]�(�y��)��xA��=��-z��$/�>s��?�<�pW��z�
���@2��Xs>M�½
Ё�M�彐;�����>�@U��:�=��龫�@�c�꽞{W?��ξ4��=(�l�및<s�i�6k��� �����=ݪ���m�?ffӽ��'�h��?�ѽ�W�}��\����8��SDn�l�M��u��ĵ#�e�eo���j(�����R3��.��z�n^�t)��q�=���̒����0���;gw>�}�<o����׽��=�G�;�\�����3Z��ԍ��3ʽ%>N큾wF@[ʮ��n��H�{�i��=�͖���=���y���NU�,%�T0����=��P>^
��8���ih<�r�� '�{.���yZ(=���aF0�}�]��\==��={N��Wva���E�͏;����6�i�U���ǭ�PR���=�Ć=���<�D̾�a�;^�=n;S���=�<��W��1�h&��˯�J���b��Md�r���a���i��=�i�XYV�������e�T՞=�V.��v���uɼ���m=�WȾMI1���=h4��E�D=7�=$�a��@?�n�0��5&=^� ��qF���7;S �W��5��#H�=�M˼x3��<��=�V����;v���*��=��=�͡=h��ԇ��䃽a�ٽ@�;�V7D���;� �;p陽g�=��(����<tt4=;�"=S��������=e���>T�s����>����3?���;41=�>E~���l�;�~�>Mך>G�^;R�>"�������X>z���l<�2�>	qp?-�a>�m�>�ݻ���>�+�מ�>�*ܾ��h�=�Ϛ��O9?i��gC0?к��-��>X�����;V]�E����<���>is�>]�V����
?���=P�������>$�
�.)$�bf辘|���龓?����Q
�}������տIꅾ�9��>�:>Y��������.�Z�J�D�8�>��K�Q�ݾ;����>'�?�V�F�V�5!�>���=�LJ�X��<<Ƚ��=*ɽ�彀�h=z&����!�V�=u$���Fu�m���K��Γٽ#�����콀,a�4cN=��ɽ�y�8�a=C岽$#1=�wG��F= !麺�J��3���y�=�@�=�.�<A
>e�>?�L��=�>�4��M�<�k�08o<tHR��4>�ԭ<f�ξ�\���<�&`=I�L�xC��v$���� ��>ν���"kJ���D�[�o��@�;L���R2z���������߽��m��DԼv]��q��`��9
�=���#�W���sz�=�KP��j=��W��g>���>����삔�B�E՛�����b�O�=��=	ⒾP��<5����`:?;:�W^�=����X�{=�޾b��;+%��$����N�����e=eG?�5 �ַm�	*�� (X���;�m�K���)>,n=tzP��5Z����<�^Ƚ,҄>-����o�X�<�t?b6�����#��D����>4>�m+���9��0�=m����Q?Y"�����c>��X���
�p���!�+@����m��;
��!��zV����-�X[#��D��;>�q^�WT��YT��|<�š�M�ϾC0s�E���HV�ta���u8=��>pz�	���
�؈�=A�>��>��d���>t�x�0���P<��s\�E6Ҿk���@�b�Ԅ�[��ko!>*Qp�N�ؾ������Ҿ�$����>����W�0�e��5֧�~B��1��,ཆ��=U�a��8��ي�;Y�<~F�]ު�O��,��>�>7��>x�=]�>/׎=��>�>lJt=�6�qU��>Lɉ>�5�=P��<��>�{=�#Y�,�t="甾�!=�t�>��?<�^��g8=�{�`���V��0��=��1�`�$�F�<sb��Y
?�z��`�>��h�!q�>?k�6����!�4#v���t>��g�x���������e=�z���=@��<�/�<p�p=j�����c�>�ս@�<�W5��͇����<+�ջ�� �>�P�f���n ��6����g0��ꧼ�$D�R�<���j���Ͻ�q�ۤA��&-�p��<�u�u�s��d����~ȼ���\�-�>� ���A�ҿ9�����`<
=��� yB����=X��=h[Ž����\��	<s��B�<�P��8彟��@�ؼ� 	���#=��y��vO�
u�>�3>\ǜ�'_����;���օc>��j��>����Og1��	��,F��S/<M#�>^Vt�yq�='1��Axv�C��q�ֽC\>���:���\��S*���,d�2Gb���by���1K�ȑ�=+$Z�u����f9<��$�#Wu���#<���������ǽ3߼TW���վ����"M�P���`S����<O޽����F<!9>�;=ܫ�=�#U��l����o�<�7���o�X�=��R�>��\��X=D,�=<4���#��/u>7�=i%�<^៼��?Yl0�Gu�=|(>�53>�_.>��9��a,���o��H?p��E�!=�,ؽ����4��=��"��`�d�?=^߿�{>n=�=�B>����끿��:�D|��4�޾����ɾo�{?f?<3A��Ὰ�˾%�e�Q9�3�9=g���l�>?�?���������ؾ+,��|{��p�a�⾭��|+?�C/��m�D��<�����)	����V�ʿ$�V�p?I\�0!�<=:
�\���������t=�d���(վ<:�/����?����kZz��U�V:5�l6��>/Ѿ��=�0.�^�>�"޾�Z)��滾A�۽�V7�����i��T�侩ls=P>=-kﾓ����{�>k����F����f>�0?�O�<C�d����W�D�¼B)�8p>>"��u!>�VF�3h�>W������=�$e�z+�=��g��ng��p׾©S��ꐾ��Y���1>,x�2;�)�o�=�D���4�<#��->��������=�ɱ�E�5>��]�r]��Y��������ݽc��=�ⷾ�aj��Ƚ��m�?��޽����?�A�=@Ҿ��U���0>v�g��2f?���i���5K���d��8g��ھ q��H�E�g��>ù{�=��=��j�4eC?C���
)	�w�ʽ?�G>W���?�"�6�����{��/�=�'�d!�?3��;�N�q�>�����_��i����<9����)�(O�=o���rn\�6@?��u�����b���$��>�T쾴8�<��ξ�i�:���fֿ;:O��c�3����;G%>w�c����oi�jٽ�*v�N>�=�y�����;�_씾���>�,���渿���><��>:��=�'˾��>�S� �M�~��`�?=ͫ���h~?��p>@p��.�>7��^-U���;����>��ƿ�h6�3�Ŀ*R#�3���L8��,�=���>gq�!��XxʾqO��N���X�>��@�2I���}��3���
?v�P���?�e�>��p> p��t�hG�>�.�� ����4>��W䌾/��j�=Wӓ�P"�A��6gU� �b��>�=���p��Z2
���6����{�l��a���o�>�漽���'!�������3�u�>��/���������X-=���>}jr��Ϳ�M>�G�>��>~�a>j�f���>>���p��>0�T��z��oL�����>PL�Z5f>����ɐ��Ȣ>��<7 �>�X:?��?����S�m?M�q�<���S�%�e=���b��}?|�1��k	�UE�'{��f�j>g�&��2�=j��k�8>�::��y5?��!?�VP�u5�<c�>�k��T*�͕4>���g�T�6�#B	�\1�<P��=ְ�l��3�ƟŽ9޷�@��)}'� >j��? ��=���0+>\i;3�H���=�$C��hn<fڽ�Žv�=)�����=�~O>s֫=�b�Ο0�zeվ�r&����=       ���(       �cľU?�y	=]��C���f�hӿ�O2?<7>j��xD=? ���̨��������>3-��s��>�����޿��=qʿ��迳?ɾR�?�2�S�Ŀ��'>.u?����vc�>�<�C<��y��&��z�>�A��Z?B��>�c�>��(       �E�=~�e���;S�)��׆������_>r��;�?!7�u�N��g>=�μ���O5̾�E��
왾���� d=�0?T�??���|��H���O�?M3?`U1>��=Ӛ=��^���]>���?6�?�?���:���>��]?�ŗ>����p�>