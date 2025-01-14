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
qBX   2003186943824qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2003186943440qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2003186939888qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2003186940848q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2003186939504q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2003186939600q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2003186939504qX   2003186939600qX   2003186939888qX   2003186940848qX   2003186943440qX   2003186943824qe.(       �:�>3߽J���='v�i����J�o�f>�������>���=9�P�m)�>�"�<ҕ��3ɖ���k>A*S?i���)>��>&R><M�=��J>� <��u?]_�>\9?�d弸{�>����1�>wy�=��?~#��#���!?�L�=��/>��?�~�>       �|(�@      �}�:]�v>@�p��n8?e\�����<��"=���=�6�>���>��=ޮ�����i.?8$�=��վ��G=���>_Ҵ��E=8���=�>��:���>�E7�b�b��>��G�N�C?�m��F��>-�ϽAg
?��ֻae���U��;Q�����=�4=w�)�s	!=&��=���=�7�=#��<QC��p2=���;p�i=y������r��=�/`<��f�	+=����=�"�~r����]��'�=vH��߅���;�f�}���1��d佶�㽬��Z~�=��=y���V���¼�a=�'7���;=�g�g_��ب=��=v�-���<�,��d�&@=_{6��1�� �%�<m��=u�=�A��9�=��g�=�;����>�A�;��,�"�=���`�����=a�C=�E��h)<.�;�1� �������=�̽�0ἼV1��ٴ�'z�в����
��~=����O��I��Y��u��Z]��u�>�K�=@�����ڿ�������1��Ϡ>�0���9�?�G�ľT����⛾u�M��tϽw�{�*�G�A�$�"�?����-���?>w{��:\���xK�7��	)�'$���?\�d?��a>�&�a��D0�`:�HϽҞ=��="˽�u�=������v�o�G<�=�<�� =]QT��6`==��=&*���5r�*�p=`i<@a��&n�ش�����ѓ�����;Y5���(<oFE��6������Z�Խ�o��EPz��K*���==[��T���Au=-T��i!�>�����������K��� =)��?��C�0�ü����N�G����=%
<��%�� �1醿���<(��<MV���MO=�g >�,��D�f¹=��輠x׿����i���c�h�=����	�9�&>�p<�Ԓ��P��>/�=�"���e5>"E�=kr�>K1?�0��]�=���<�̼4{�~@�;�ke�zT?���A׾����e8>��^��ȿ��޾+���g�1R��嬽G%.��pw?q#��iȾ���Y��?Sl	�yb>I���;�����Ê�=x`���{�^6_��PQ?��#>=!䋿�ǿ�U�>��d��}�S�>�I
= k�z�=.�Ѿ](���e��t���=��M�}>�C*��l�?$�+�ߗl�PZ'���l�����������_�!^>��L�?,4�>
)�G{S��J&�%��F�Z�#ݾE��?��s>���=��?�ܯ>��x��җ�G|��X�n7㽋É<`��;�7�>�����b>���ï7�������>�a��^���K�'�d?hZ��M��=[����k>ڡ`>��<<�䅿d}=�;�<":�?��K���c���M��������ZFx=��o<յ�>�+���п��<�@>�H�>l��=�Kֿpu� ����� �����=�E��~�=��8��Ӧ�XV����6��<h�?�	�n?����7s�k����K�=��%��˽��T��� 1�������f���a轺&�<ϴ�j�7���4=U	l=�������=~d>�d���x=u=<C�A,?�1D>B�оy����<p9�<Q�j>��:���6?����Ҩ���]J�m�ȿÙ���S	��`���:�4��>d%���#��>E��nq-�⧛��d�>i���)��45���x>�U��qb�  $?d�F�. �y�#���&��=��e>;�?\�l�愃�R��=p� ����=u$�>U�K�-d.��l��D����=> �$����K�P�=�>$��z;ϼ'�M��>��q>�(;����������<*�?��ǼϿ�(&
�7n½����L�TL5�x�i�8�;y�ΎL?}�>Z�>��=�Ի�d�e=��w�<��G=Z�#F� ��8;��5�-�g�<�/�=��D����ٌ�����nc�=���y��!��� �{��6�W�= ��;z��&��rI����[F�Tq������#'����=��c�l��	��b���ѭ�4EB�=�S=�>�=��T~��� >���7��m7<=�-����4��K�<y	����=O.���=Ϳ=;d�P
�<sf����ͽ�E���ͽ!��=�	�\������A�߽ҫ�<*�3�0�r=�Fӽ��
�Ԕ�=jԴ<�0�&�(����=w�=|�:�ɫ��8��E���eZ>wY��>�=��A=�V<���K�a=(-���@<�k��BW<1H\���G<C�#��x�=���=�1佴��=L�-��������x�Ѿ�G>h]��"S�:�=1�=9�F>V�B�X��=B:s=�.�|����D>jC���fܼ���=��>�9����>^0��l�W��=��<���>=-�;�F�7�W��u��kO>�t���Ϳ��G;d[�?��='��՗ƾ.�Y��d'=b�a=8�F��y����u��@�P?����#��=�h���ƿH�˾ ��=Ҩÿx���Lq���-=��F>K�^>
�,�T8!����>m]w�
+O�%>��H�MU�>�u��E���4����-�>��󿻀t����ֹ@[����å��k����>�*�>���|��?�ͽN�w�ZB@F)�>V�y�4Ř�j�n�CZ��[��y1>�K���.g�<��2��à���E>�����1�7~=g{��l>=�Ć=?�����VS��vf�=8�缽�=P謻קj�:�]��嶽��|<6��$�������NVս����i�o�g�g[�ۯ�����=qH^����6�U�Rq#��\<���O)��R�=�߽��µc=$�a���*� "��z=^� ��qF���7;.���*�&	>�O��x3���!>�V���)!=D{:����=���=i�>h��ԇ��䃽S��������NH5�w�.��.�<p陽b��=N�VB=tt4=��]=���������=n���>�ӽyX����9��P>&�ڽ41=f�>����ȵ½em�=��<����|
=gnr��J��������^:�};�=F�L�Յ>��>�@��0F�;n�A>O'>��<��@�'�F���T��bS>�t����=����}�0�����#�IԎ=����%�1*S��@P�ν�9���d[����=�X=R@r���=O�%��wQ��[$�x/�����>7�#��4�2)�=�=Ɣ�=I�=��\>�O�=�2b���<�(���������	�=��9=��.=٩�<� �=�`��U�X��=�t��
������\};X��<n}]���Y�)I`��彀�h=z&���j��V�=BaA�M$8�C�K���9l�@ ���q�@��C����Nd��?��8�a=C岽$#1=���a��4��~&;��T}�,΃��@�=�0ؽZj$<鑲<?���k:���<�o�����<�k�08o<�/۾�����t;>�h��a�¾��<�	�=��Ⱦ�c�7��I/D��)���4���?>f����־xX?��>���kx�:"
�C�&s�>c��*��e2Ľ�
�>y>s>������_D���&�>�5�2��=Q7ʾ�g�>��>������Y�ȇ<J0 �%Q��=>�(�ԽP��<_�+�#�羟��~/;Ħ��4�=K����#w>�����a<��>�W9>AGž��!�=\i;},=�T�<�X��ΏӼ�=f#>�p>|�����.��>̌��������$'>�.�>Nv0���$��5����=�?��[�����*@��0�=y���tc?�>����q[>(S��o��	C���:�ϣ��{Ͼs@��s���	��Z���(z��2ɽ�V�>�Ю������A� �e���$����>�-���T��P�s1Z�_���5���>K�`>X�P>���Hǉ=HE�?��>�|¾:�=t�x�yq!���I?f���R߿7ъ?�o��D<>(?�9";]���T!{��X)�s�Y�aH��8��>C\>DI�y]T?q����0�S��U�>Wu�����aĈ���?�o��*�=�@���٠>
��|��>i�V�-�>Y����>��_>f���ue�lJt=X����A�?=A�����%���������x��#T�L_о7��<r���e-�!��[;���&�bGp�a�>�=8�T��q��Ԍ8=0�>�J��ɶ��C۾t�:�a�_�`k꿢���L��?�(d>&�����?��Z��`�<J��=Q/���={��<�:�.�?>�>���G���K��)�K�����<�=&�{=��p"��U<����8���5�������!���PѮ=kXؼ@��ߜ����������
�u�������0Ӽ�Ɵ�-3ὀ�=��,� uԽl��Lrɽ^�>G`<
=+a;oА����=�z�=z�S�Ž=hؽ��w��=k=ƽ�r �W(=nJ=;hm��B>:'%��|����'?��g>6l������RN<�Y��ܮ>�w���ln>V&Q��+O�&w$�J�s��?N=L>�4��^���L���0�C���I�C\>XЊ���>��
<S*���.ֿ2Gb�F}�by��G��=ȑ�=e`�?u����f9<O̅<}u�f���e���I/���ǽ3߼�1?�NH�����vl,�P���`S����s�M��<����н�n?�	?O*>�T��K���UQ���{���i��?�=�潲c=ςu���<��=� ��
<�����>O��=��
=���!\?E|7��4�=��.��ٔ>���>I�^<ʟ��ڋ���j����?Ҧ���$=SB"���sk:�P�%=tqo={y]�8Rh�����=��T�{�>+�>��Z<�J�1>�r�;������<�ؾꖩ�tP�;j`+>u�O��к�?w��B>�U�;4�Ͼ�l�K(>�l�z@>sq^>��<��ڼ��f>Z��=�Ϧ�>ԣ�\dB=���=i�n>�ч�˒�=�n>�K�<����%�p���e>쏯��y�=�|ľw/?s�7��똿�M��<:�pg��5��?pоY<g���>SYþ����UBٽ��^��y#��QK�7A���צ�v������r�!���V�J�?���3>���*��3�;2������M��گ�v?��E`��H�!�`5˽4:?L՗�l���/����齘�s����=`��>��ξu!>Oŝ��7N?!e�>�#,��)�N�r=w�X�j����O
�Y��<r���9�>���#k"���wľ^��,d���C=� �>M~u;߾併�<>V�>�j���ް=���=�\��A&�� �?{]4��?}�=sh�su ?�p=�<׾�s���A�=�d�>�k𿝑r=Cɬ��h?�0ž{�P��1;2d>W����aQ>�'���TT��$��N�S�w,���B
�w�)?s����mѾh��>ܓU>.$>�%r�_�5�FM���ھ�9m��m�?�6>2����FD�Ԅ�K�W�sQ2>�=lK�=CV��A�>o���	��<�׈���e>��g�y�?�V������L�q�8>��h=��ʿ�;�_���I�=�>�*��YY�>�.�>T�3�����hK�ʃ^��%Q���>1�i����<���gR-���?�h��Kڿ��?>z->�N�=��νm�C�W���4�=2�=`�?=>�X�Aw�燁���齾���*"���*�;����	�'��2�r,��N�>��λn0��ĵ��iҽo���H�a?��[>�J�Î����B"��v��=�ó����=>&p��E���%��ゾ�D�>n?>����`�Rt�=b�,��`i��`O<���"�;�$\>0><qY�9Q=�%��Jֽw0��
�<�:��͂������s?�7�=�XH���=>�k���>��">B�Y�Wϼ��q=�������f��h�!=w�y��[�=�4��zA�l�\�m<|�����&�=��>'�f�\����+���5>0�T��lٽ�Z
�%�>��Ij>^b����V�,32=��?>�a���?��=(h�<��<0��@�8�_ރ=cD�=��u���H� I�>E��-Φ��ۯ��,$���ڽ�!��6;��IR?��|~U�"�B>�6�=����d"�X�=��8=��?��%����_��%��0�����>��>�-�Z_�sӽ`�>�A>����͓<e�?v;�=��ݽEm
���;T�=�K#?}�?+=]�mPp<�Fx>U3þp}?�d)>���>���=>,?~�e=u$��l�����h�`�(       �);���,��Ӭ=\��?���ϭ>�ͽ+� ?�E5������!g>������=�E��.����ƾ^Ж�Q;4����� (���-�P���)M>�˗;�$8>�I���j5>�m����R�?�Lk����x*��y���?�>�^� x���������>�]C�(       �Ͼ�s?S�?E]̿���=�f��.$���5?G�6�����T�s?m�@��⾿4�>��o>kno��q?�2j��h׿i����Qۿ;�Ͽ>�Ͻ]�Y?�ɿ.�@��$?s2�?��|��>h����8u=�%���rj���?��=��?W�5?9T�=F��(       �b�>�|@�Y�����Ζ�>
>�/�>��Y�� |�#iQ�����/��>�����_=p����K��C����7�����-?��>t��>�F��l���G�l@<������F�A>o"6��Y.�n���>������t���r>d�=@�2?