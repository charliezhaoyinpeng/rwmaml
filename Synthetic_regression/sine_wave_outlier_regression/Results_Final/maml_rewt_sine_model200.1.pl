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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2132430949232qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2132430947984qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2132430945488qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2132430950000q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2132430945200q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2132430946064q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2132430945200qX   2132430945488qX   2132430946064qX   2132430947984qX   2132430949232qX   2132430950000qe.(       ܄r�M�eGI?b#��<����>;o�`=�q翭7/=^��~͟;��!?(�>�����~�/�޾wM�?��.��*�=W����������=�/)��PZ�$�ٻtW�H�Xq>?�z?�>��L�����pd?#m0>Ӥ&�#�>�?aГ?<>(9��@      >�M=4#���N�lr���DK����< c�;�<�%���$.���Ͻ3�=ԕѾP�F��-6���	���ϼ0�i��	��f���"�N��O���N=S��Iµ�
��"�T�E�>��	���=m����Rþ����1>��{���ƽm`�=�=wq�.^j>������Q> Su?����]��=��5��/
�<Z����;	�<���(�^=�jݾ+ཞ`�>-Ƚ�x����9�st۾��%�aQ�4<>p���FR��k���O?>��=t�̽Q6i�әN�Y�a�H���[�߽��Կ�D�>T��=���Sq�>�+5�L^����v�&�-D�־&^��f�V��̾�r���yl��4I���A>�0/?zhE���>���9ཱྀ`k?vA2�����������_��耿�����R��?�꯾ ? =�N����z�h���������!3��}��>��K���;0�w?lx���=D&�=�����P�>��<��p�����A�%Y½se��J�ǽ�h>и��r��Sɼ����=JG_��Ӧ�-�a�Ѽx��0H/�
�6>��=��=Qv?a��=.��=_o��C)>L,¾A.,=��^=Vm���r[>t�N>ēs>�U?4�x>��=&gμL��=2G���=���=z���N+���v>�fE� d]���=*��<���O�<�d<K���ag:E�������<xJb=x��<	�<=��J���E��T��Z�����<�'@���!�s,��*<<
��g%���X��=J	�~B��H0��rS<*cM�)�.=�$������������6�<��нD�=��l�~�=�������L�<���	�R��ܘ=@v2�B��=Y�����&�=�2�Dr���ؿ=@���޽J4�l�������"^��_/��6�Ɉ=��t=�=~�5�Z@�������*�>�m��8^�>hU;��E�㉾�;@�c�Q�e?`>�"���h=O�<�o�6>�N>��{>�M�<�5>��k���>'>	U/��~��P��<˙F��|����=��=�Ә�o�aUC>����)A�>�1�=_����&�������>��ۿ�������>ξ?{��>��SuѼ�����R=���-���3Ꝺ7��tl׼l�=���>O����	�z7ʾLD@�e��+\<A��>����|`�(�վ��H��m���ؽq���S�Ͼ��?����1%����>�k�>H����Uy�3��?�R�\�}=��=��=���<z>�P-�<0��= U���/Ľ%��<�b���1\�*�̽�`�+8=���e뮽���ɽ( ��C����什V�F��Q���Ѽv��L�u=I��@h
=�%�����H��=ykȽP�&����=Kl���������̩i=�� ���������g+����4�o��K鿭����L��2�<�A����>$�d>:�,��{?����m�<P���?�Z��
�Q�<y�Z��>���=p�=&�>�� ?��tM���n >s<�����>q�>���|�G�E�q=�t>�Go?2U?'Sj���ȼD�?�G,�ίV��㎾����� Y�b���"��=o�>�T#�Y��d�q=�,*��j�������o9��R�=�̽^ͽ��>��)��茽�MJ���=���׵f���N95��I=l��'5��GO��s��O
�I�ν�w�� B������ʠ���=��3S����=���>R��g���H�&>���)m��>0�T����>_'>�w?@`����
?5"��؞�>�Jf��S�-]�>DF�=� g��sd��.E��"?,��=���?L\�0�~��Kw?'Y��Dv=H��=�7?�F^?�/�7&A>��V���?0d��e���ś=�s�=�罞v?��1>�>�����Q��>�>� ?�n:;�h8����Vg���r<���=gۛ����=�����=_�?^�L>��	������7=N�����+��>�a׾d�=��c$�ay���=��é>r�{��M�E���?�+
��=Y��X�����=�Q�<� �<!�����O=0��� �=*�R��a�OnE�KG�[)��=
���'�k�F&��fQ��v��1[>K���t轏�2��T
�@���m�=;�<����A�=�m�������"Z=M��=.�1[!�&I�>f�?�t=��H�NDL<�Es��}=���=��U=>)��!�B���&�iM��B?8Sg���=Yh�n�>��n��c�K�
`��9¾��V>��1���׾�>2��t/��DW���><����,�&��>�֢�]u��:�ǿo�&"���
i�1Jx>K�G��L�=���4�JR���9��' >߉�>ݛ>z�U� ��^p�>��>N���C���C= >_�哀>�^=��^`���5��տ��	ӽ���%��1�=�W�	y���p�{�����>GK��2��Rcپjқ�� �c����w�|�.�h������]���V�*>��T��h��ܺ��N"�=>���� �&�>�ӥ�J�ݾ����e�>�HX?X�G>���=c��f�m��0s�F����ц�A��?�r ��>����~�c����>c�c�3R�ՒX>!����4ʽۛ��ɫ>��
�5�`�i��=6G�b�@�20��yG�� ɕ=c�<˽���=�4����7�����������UL<��_�)k �w�ཿ����*=����|�y�I��<��뽁��L������<�����"�#���&�!f����[=��K�=� =�?�<�%�=e����<Z#�HA�=�uR��ၾ˥�	���AؽW����vQ�n��=(NI��\y�e�Ƶ6��6�7���V�5�c?;�����G�=s��1*�a:ؽ��=��ٽ<�ǽ�����>ᴀ�����+�P�1�͏Ҽ�rԽx��\�f��+o��E;��đ��K��e�>�CP�!d���7a����?k�/>ݱ�"y�>�S�>�ف�W�#�,�?W[��Ӿx3j�R6S>�R?v,�>hy>�E?�	ݾ8�����>���<A��>�f)�PE8=>�>�ז;S�->�,5�0=�Ż=��ו���7�jK�?Uö?���>&�>��>��2��>a�����L�g>�v>7ڛ>ͱ�>�Z<>58Ŀ��w=��T��?�n�?S�4�K��<���=e��<l	�s�>�Ȋ>��w>�[Q>wr�>��{�Ƒ�=�k��'<�>�z������>_>��"���>���=e?>r�>���=�p���g��o���T�=;�M=~,�s形is�9�,�!�x��3?���K�����s�e=��<�yw�~W���<��&�N�|��ּ(��=x���X�Z�t���>���=PP����،��E>���<�'�������=Ҳ�=��ɾ���R�=����n�N�/�K�<=;Ž5ɼ�����\�5�"� {7�ʴ�=L�?��t������]���1��f ����F� >C�:.2)�9����9��9"���4�+}>7��G�=���;R4�=\%C�;�(��{|<�z*��E��{)��z�<y��=s��ޖ��z��r�C>�ʲ=��=�ۉ���=z.o���C��{Ž9[=֗@��w�;��>�,>?�4���þ�^��NC=�r��)G��Ͼ ��r�	�"j���N*����&�=�����f��[�Q�><�a����=�}�=}a�P榾٦�u��>�ZH>Rl��p�ٽZ���P
�J����u8����=����hѼ 5��8&�<	4�>��P0��L���J�����>����ٽb�/�����z�<�z�0��=��ӽ�<=�=�W�=��"a����=�qv<�l=�'F��o�<xo����7���������⼅�I��2��蝒>�ױ�i��d����t�t�<�R��#P�;�F6�q���dw�	������"h���*�&3������@��8�=@�<��X��.�y��?R!8=�Ó;՛��w�� YO�D���pj�؞˿�+?2��<�*�= =���>�岽�:�ոn�/-$�W4;��=�9>�+�=�o���I[<����/��=���N �9d���罍���1ֽ��M<��=A@��������w��=f�q���ȣܾx�=�m��3�>�Э���>@!���'��=��澔�	=ch��%��<P>w?e?�=�C?�[۽G�7?���>�}�����1�>�V(��E>�$��"�X�y,�ω=�
�>���>����wq}>���
�P[?!2���ܽ�b����ܿp�q��C>��8�ߐټMS?oU�������>c?�l��G�V>��ּq��=J@w�;�9�碊=��ɾ���=�ܾ9��R8�>��>ɲ��3�<@�>�Z���̿!r'��@��ف?���R�>Lq��r�	?�ԟ�$�?�)�� ��D�$>T��=��
?T��iZ>(?�=�r�?�^G�ݸ=͏?�8U�{������<�Nl?
i�?M�U{x>��>�?��x=��0=��'�d�r�C5����>�v�=���=u����_�>'��>(J��q�4���=#����ٷ�k�}�o��mh=���>蚽W8>10��8��<A��>�M>���Wl��ѧ>^Ք���=S8�=:�� #>��t�dv>i@�l�>���>�>��>Β��ZTR��H�>���pǾ���=��Ǿ���?)����?)��=:=W?I��+�>6t����x#z>� Z�f>�jv@�5�ҿ�������G��M 5�Uc�>�S�>ӆ4�_�\?z>\6�<�7=�X��0˿��&>;B��R�]����>#���׏����v{���]����=߀��E H< "c=�ߨ��<��9�>�
�>k^��xe�w"��AX=�Ƚ�R)�:��u�н8r=���?�H>l���x��w97�d�C��Ȫ=t�ۿ7g>X">g���s?v����A��Gm�z�y���徎m����TV���xvݾ�}��ﶽgH�������b?�}���H��v���莽=��C?��>�ڟ<+̾v�+�����Y5�x�����@��+�HzL=e�Ծ���>��(�;�E
>����az��6�<���>���QUE��K�>��/<=�?/�O�}tI���ƾwB��½��>�	�=��л���>ᔵ>�>��G�j�1�>=J؟�H���]���k���:��~x<�O��i�/l�>qc�>�N�<�!ž�gC>z�G��.f�n��>�(����u�}Le�w�>�S�e�M>7R�>�&�=3�>�p�=P=������\+��Y� ?��>�=<Af�����U����>��y<K��>���G�?��=))��u���#����H/��(��R�F����=1������1�J1￨A=��r��g#�_^
>�ϥ<B�����}퀼$��>k{(�n��?�y����t�����%�z@�>��v>͵�>��h�r8=��?�=�=ʐ"��g��=��Ao�=��\>5���ܖM��h=�!���;���ߛo>�t��ڀ=?N$=��2��.���>@9��o�>�!�=.�.��?u�x�jؽ]��>z�7�Y�@+J��pn9�����<���$$�jp�>��Z>�5�>�7>Ơ����I?�d>��h�U���U��k��=,HI>7R"=��ҽ}e>��C��%T��5��.?�w������*Zg>��I㽽 q�>P ���󾊿a��g�;O�>�}p;�7��aj���=;���b���с;ͱ��֗��D��۔����B���t|�>��m?Յ>�(8�����-c�����?��	�k���fK��
��=��R�&��$@u�Z$v? �Խ@���O��JP�#S῏��>_�������>����ذ=�?�ӵ����R]�=�Xh��f?m<��'�Єe���[�GO��^�>���=�^>,��jN?��>թ=�����_�=�=���}h>��b��l}��`��Z?5�k`��>��>J����wȼW�=����Z
g�.��>ߗ��;�=2jD����L?�+νL��:[+���
Ͻө =�.�䨽��<1d-��C�=����&�v=\��U�:w�<�|�<����t�ۇ.��~�<�sａY�ҽv=�À;>2��2K��9^`=lG��C� � =��<=ӽX�)�5W��(=��=����̽�c6���=MnK�       Ҏ-�(       \Lh�5"��>��>K�N=h�!=�P#�.Aʿb�<>_���l��Pҿ�п���>���s�=�?��Fvq���0?'�½r��h{����=>"��2���1��J=��	�z�7���<�����j>0����Q���h3�>�����=����=�EW�(       ���� �>�������z;C�����s(� U<�S���>5� ?��:?Y��>���:2?uk6=�<���>a��;��>��<_�Z�X>1�uKU?1� ��ƛ�yE��t;!?����Pi�T:.?��h>&��>N3?�!
>�E�����݁�f�T=�l/�(       ǆ2=�B>?��>HH�r.C��E�~u�oN��8ʼCXϾ���\Q�փG��K���ay?���>��N>��b�*Lͽ�dV�q�=��r��X;�e�Z�m�D��<C?�g�vP־���VSW�adB?,�>�
=�.��D��?;�y���ʿo� ?� k�����