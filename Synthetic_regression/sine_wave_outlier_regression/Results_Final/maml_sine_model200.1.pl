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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2130892346064qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2132430926864qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2132430927440qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2132430931376q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2132430930416q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2132430927824q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2130892346064qX   2132430926864qX   2132430927440qX   2132430927824qX   2132430930416qX   2132430931376qe.(       �%?�2;���)>L�	�����iDY=qO���W�f{�Oh8��A�ý���c�>>�?��>�n@?��5���(�>(�>�_�����ٽ}�e>�t ����=��l<#a8�H'��= �k�K��k�2?��>��n=�V�U�>e�E�.?1��UM�(       ����ż����=�Ь>H(�������>|��=q8%>j_�����>�jT>���>4t�W���aL��F' ��?�= ��<�%����?���Z�F��>�1�,�~>�y=��>�6����D-�=���-�=��/�K
��=>Ҥ�=?׾����L�ل�@      [�=`����5Y�@���˜<�X�T�c�v��C��gY��xt���L&��\(��T>�k�=H��"��Ojq�R]ýA���м��dϊ<�L�<�X�r`z<�B�=���V�=30>U��q����4�,+��������x��A>��"�֘�=��=TϜ<#������=˳�=�K6�1	<���fq��B��#�ѽ�j:��e��
{=Tˣ=T�r=Նm��u=�tC�C����¼}���� �=��н&G�=m���K?=�Y�=��@���t��y��~������^�6��*n�����L���!m=���+�rj)?�e��%�f�O
W?���I���t��/?�ax��C��Z���C��=�T�F����@�1�Y��R�����f=L=d�`����=��j=��:����>r���N��r�>�Օ>�c�>�Ѭ�e2�o]=}�W?��(�G]g>x��> X�=> ?���=�@S����>K&>H�=��>D��>
�J�- w�u'��=�2?ת��+-�d�����e>1xѽ8n�>A\������>����<�ݽ�?¹�="����>������v���T����m� �NC���S�<V�+>x2�>:\=ʓG�ֈ�&;�9}�.���:���?y?�>t��>�B?�'�F��?r<������>���>�ξ]T�����֯>�2*�D@���6>�չ�M��1$>?�]�>$�H�O��=T>���_�?
�>fŲ>|Q����>o��F?�ru>l�վ�a��<��?L7�4B	�̔��\ې���<ϕ���z�8/q�XQ�����W#����/�pk%����\��=̎I���<)xI=֚����ן^��\�m���:ӽ�a��^y��|������$^Q��͏=.��X�4��I�;2����*�f�:�&ܽ���
=iq=�� �������c?�i�>n�#���>tL�>�GR�EG����>]���zʿ�9?d��;jY'�[Q��,��0[s>z�k>���=j�i>�"��^}=���>@zj>��#��`콤yݾ��
�0��>M5U�p��>O*L���Q�:T?�t�>C���]�����>kľ�1ܽ�uQ�8�=f;�p��I��>DfW�8�:���~B���>ȏq>�/C�=�2���X�<�#�0�I� ���2>^J��|ڽc>5�F�0>j8�>С�;~��r6��~�Ȏ��'�|�y�G}���=�"&�s/ܿ�g�=��=a�:�z˺�;�>�S���!?����Y����?��i�'��<���EU/>��7���!����`�>�A����B?㳓��7?';4=X�>أ>�t�� <�?RB�'����y��$�d>`��PX>4z_�e&.?�M��L.v>Ŝ?R!������9�ϗ�ajd�x����׼r��:��=�oG�u��<�; �*���]L���&��ᚽA�<�#½�7ֽP7l<\q���^�� 8����{�=J�F���=��A�+ֽ5V?������I�A�e��Y���0M��ݽS�����=Q�D�J5��P����E�j���'>"�==>Ϟ=NUI?��⿟�0���ۿ�>п�?��@���Ծ�&�=��q?Tc}?r�X�ȅZ�q/m=-�����z�x�*���?����R<}�>J����b�,��=J#����V?r��G(�ʟ*?`�>$6��6�&�B%.���4�ƵD�,D��b?G�s��{o>��ǽ��=`���f������o=ԏ��R� �E
�=�p��~��@�=�;<B`>�G�d����=�u����=3�����P�����=|�!�+Ã�����L�f=_>�F��=��=�Ȱ=����ҡ<��=h=�=�W� f,�'=dBX=�sߺN�&����?u����T^��S�%���R�=�=����=�Z�<hƿ�&v>�
���Y�>�s�>ន��f���5����_�#>Ł�<���<g��=������s����E8�e��X�>��a?�:? f���y�+(�>y�@T�>L��>�F?d�.>�;(?O ����<Yt��+=��ѽ����Ǆ�A�u�`��Z1��7h���0o��	>>��)>��g>�e�<�J�<�Ծ�'��XL>���`� =��J�L�+>��־���=Z���>��z�=Sl?�u>Vy�6�>`�=�R?r,>��=��2�Fl�<#��<�!>��>�bN��v�=^?��n����=��L��W
@�6�b� �~��>h��M�����'��	?8�.?��9��`����p�D%��z}�=�f�>�f�<� ��I>�>��)�Q>D1G>�-�<CT�j9������ž��8�6���f,>λѼ��8>@��<A�3�صf���y?ʰh?R�+��-<?Ee���Y�>&}��7��Ѳ���gj?0�X�7��=�ox���=�aB�>d�G@.�������\<\��=-�)�$D����xa=&�e̐�N�>�N��?�|Q�>9������>kĈ>{��Eᙿ�Ft���u>�K=�����>}�=Lw<����y��H�t?X��Q�?��>s�}���U5���>�PO��sȾ	3�=7�)��\����(=YKο�+���S��h����=ȡ���I�I��>B��=�[�2	�������i���R������ҽ�Y�<�&���r�=��=�%�>sҚ?9Ɗ=��J��ؒ�͒�?̧V�z�T?'Kf?���um��ג����S�Z�ƿ�5�� ��8=��B��̈=U{.>�Ţ>#ʍ>"�>4��?+=�2ͽƄ��!�9ހ��Ϳ����2�	a���?T�6�߿�z�>�H��3��ܬ�>n�K�d�����8>z���H��ռ
�TꁿB�ǽ��ƿ!d>h9�;��v�������f����yp��]HN��h���\?�ΐ�=�\<(��AQg�h�=T�?O��>�$*���?���=��G����U���ٿ�o>�.����D>�V���5=�d�R��=��{>�� ���»���>�u���&޾Kdl�Q!���-?	�i�د�0H>'��+Z��kN�8�����=H7>3����Խ`�1�o� ;{��� ����{]?d�1���x=�?J����:�H�?�R�=d¤�D���w=Lٷ=�xM���^=KA"�Ƃg�57=�����rY����p>Z�O� :3>JA��4�> �>:>�	����>�9@�:m�����Ȟ>�n�>�Dz>`Db>k���t ��ӆ>o�F>�����!L=�!�'h��տ>��5����>;���3[>�·���$���?������>��O���o>W��MT��*�?��#L> 4�>�,���?�녾�H?��>� �����a�->5~�>3���{龡�վ�xh=f������=2o�>sf޼�1q���㾁�1��۠�������ۿ���� �y��<$)>����y�L�T竼Г��i�-�`��B9��� >��L�Ɋw�%9A=��㽬����ޙ�*����н:�ӽ�'�Ǌm=0%���=�����	�;��
� R:4s=��������M������-R<8=��e���ֺ�U�l��<�<�������	��)t�d��<3i����Z� �B= �q;x�Ƚ�󠿐f���r���>>��V���IzҾt����#?�<	���+}p?Q���{��е��P������?[	��I��,6�C�� I~<� ?��4G��о{M��lR�?������j>=�=n1>����LH��5�F�-茿�B���"��<�=�F>t��>t��������?I)T�3 �O�F?:�����A���G,V��cN�#�����>�����D�a��>��4?[�>�l#��l����w�"��=���>'�r=�{@?ݓ��eHn?�F�����R-�=3A���Ǿ��?��,�r�������pC�WXW�}���"ܰ���>D�= rľL���ϣ=������f���=H|0?qRu�Q�>��8?�+��Z�m��KT>�ȧ>��>1YZ��K��mT��T��'ʓ����F���ʋ>y�ɾD�	>�.=SU5���¿߽u1����B�$\=�ɿDk���&)��u>F7d��9�&C~�L��>�d�ʉR<[�=��� '�g�<�V�@��}�nY�S���e�l����=��b���@�-�g�ѢӾK�a��u�=p��>!�&�
۟��>���]?u�� �<�?>.�>B��>�倾����$�COB?�^�����=�w�>���e��>Z���?���>(/�Yk�>B�w>�I0�o��==?B�w<`n�DP翑�r���?����z�>jַ>S/�J�)�f!	?a3�=[���ǉ���?�b�ˋI>����]S��1S�=d�=����!���C��p�>B��>B�>|�>����=l�;a|<w������<[��F�K��|@6=���=^�_=�ϊ�H���aн������,����=p-d������ƨ=	̽"iC���-=�Jǽ\h�<�����`�xg��=3���j���A��:P����=��M�rP������+�=ځ0�|�F=��H><�H�L�R?K�?��>��s>\��?G*��"���߫��f�?����&��.4>>�m�>c��kOɾ `2�C�����=�B�����d4>�&=�m�Y�?��\��ּ.Ȧ�W��<���D<�R�>��=	?i���U>5|�A�,�U�&�QT@>��=F:/��->����X8�@=��=-?��b=�ν�%�>�M��QLA�ȝ>�c8;��@�#���:��꽅aH����w���M/�������D��=�����=8�>�k�;�v־��ᾏP��.2�>ƿqqu� �<�^>$i=H��\�������-�"?�e��uG/��N?�mX=��C��ؔ����Ë=��?:(�>r��a���og���=�#t>ք.?�j>(0�fl�>�B$?��f=�NN>[��q���]�K�]�>B���=�2U��^�ч?�V�=#U?���f���{ǫ��!�F=����� >��>�A;�Ƕ}�bW��HΆ��0d=��ν���=���a��3��s���>�S)��h���%ҽ/+�=G>���=p�f��V̽Ȳ�<@W$���-��o�����[]=Z�&:@8�<�E��Ӊ=�R>�+�=��ҽ�Y/�������(��>�1����>}u?�)>��!�=2�ھ��@鹈��e"���$?B	��ԥ3;q�%>�<l)�(���淾AĮ��v��:��=�'�=�:�����'�ؾ���<.�V?R�>r������>�Z��iݾ�ٽRtZ��nž�i%��/�>�>��>B&�uJ>�=�Q�>{�����P=����
)���??Ą�<��5?�az>�e�Pd �Z�g�`�#=𦾉�Ծ����2�Y�`�!��|<L� |��oE�ʣ�!O��8g�<`���9<��p�J���F=h��]�sg���Z���9��A ��>��/<V�ȿ��=�F�ƻ�o0>���>��A=�i>�� ��Y(?}�0���?^B�?���T��G9�d&V��Z�՜�=����E��F�<��>�+?����`�?n����U�?ㅮ��1y��"ٿ��f�,�_�U���SA���
�T�!�u�����W������N���e.+=X!��O�>�2�?�����=���R';@��3��q�O6�=nq=5n���s����Wvc�� �<���ݏ���{�����2'�>v�O��߾[������>U+��[��>D�ܽ,S=�t�Rgn�����>�
�2U��͡>�8�=�_�>�Ν�K�׽�4�;(���;��=&k"���=_0���=�F!="HܽҴ��}�G�g�<�#-�>Q�R�=<y���C>�?	�w% >ڦ�<"U�<���=�=�����b�=̐Z�)a#���V=3*�<�j��m{��������<|��-�='�9�H�ڽUi�\�?!�,����>%�[���GZ,��M>_ˤ�\A=�>���.��l���w�� ���7�=m<��
:�=Y&�>z�N<�O�=�;�=�Y�"K��"XѾLdR�d�=�`�?>��=�O�>U�=0���Bn�E����� =�D@�Kу>q�A>�?�>KΧ�t�� �7K=F˩>أ���f:�=�-�{%?�>��r��{�=>��:�\Ɨ�8(轑ߵ���y��F���-�r���Ɇ=!8>�l�;r4��7���$�l�\6�=�*��	��u���<o��O��(<���9@��=���;Mͽ|.�=�Խ       }��(       j�l=��O=m�?rm?����J����;�����)<���v�vQD��i��2?��>�̖� �)@��tg?敿x�N�� �d�
�,9�=��?֦3?��.���L>je?Yk�;7³?A�C�id,��Sֽ%�?3���Cj?�p���=`�	�'z*�(       �8����������M ���=��/�V?��7?���>!�c<�l���"��x��$���&��^l�>wm�>��	?�lv?�-j?=�?���Xi��}��>��=!ș�l�˿�t�������>��(?��7��v�~�W�qQU>�*�;_�G��-����