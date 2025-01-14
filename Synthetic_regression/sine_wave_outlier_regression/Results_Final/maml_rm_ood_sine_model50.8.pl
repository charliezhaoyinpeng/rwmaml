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
qBX   1550967529296qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1550967529392qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1550967528720qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1550967528816q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1550967528912q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1550967529008q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1550967528720qX   1550967528816qX   1550967528912qX   1550967529008qX   1550967529296qX   1550967529392qe.@       ~�KɎ?O�?�l�=VH&�2� �"�'�o��>���>)Y�>�TϽ�cx��D]>K�s>`k����"kX=y�?Y1�>�[>Sf>�:��/s��N�>5�K�^�=^ =&�y��>[��>�>%��0�>����a�>��[��Z��q >�����=Ʉ�>=P�Y�?�$2����p�;�=P0i�>�>��ƾKo��x�=����,���m,��d���'ľ��1�m@ ?�A���ÿ#뮿����e\?�ȋ��7�<J�?��j=�S�Rs�>V�>�s�P�@s�=ċ��5��>��>a'����>D���T�6#�=03A? ���P���W�Վ��hى�҃�y!�I�s�V��=����Dؕ�1������3xƽ�fǾ�D?[ƾ�d`�H(��m��sf?Nz۾��=�|���¾�Ҭ�r��=ƒ���:q�hI���ɞ2>���>9˟;�E��i����`=�,��e���c��i�����}��,�<F`�##�q08����=б��@�r;��x=S���ټ��>�
I�.�=/ʂ�ݝ=˴��͆=u����3R��<7>�`����z�`����^x����Y�`B���f�=-?��Ͻ�V6��G��1����<�ϐ���ǽॳ=���� ƽYw��:ӽ��@��ʽu�߼���<�_Ž�K¼�a�=>��=�(�Y���={�ͽ�4��`>����P���ɽ�֪��c9�w�&�������|Lܽƭ˽��=��<���,����=��G��|��r�gQ����v=7i��Խ�=�?�����U=Ո�ǟ��S��cu�l�"��le������h����=~&���e��i.�u��3@>�⨾���C6���zI���Y?�B���)��������M���Ӌ�����%�͓M��@N�����!?��>��;�Fٽ<՘�Ӄ>x~
=��=��@J$=�W>���_����=vq>��>>U��_�X�>�`?�2Ⱦ���><��>���>Hq�=�	ž�T?�9�q�����>�����'>С�=��s=x�O>��g�^�<�>���Y�F�T�Iڱ���@����>���ы>\<�� ��,���T?	�����>}ݾ-I��
���}�uk��G>6$�%V�=�,;=�þ.�_��k��A�������hw�/b���Z���>�ͽMi)��I���T�kQ�vǏ�6+��������sՇ�����c|�>�X%?@Ϣ�/��<�}ٽ�΅�0!����Jk�=�:�;�߃� Xp=8]>�����m<�i�;�I>�m轎�(=���=��'�3�3<<s���=��&�����٫=�s����? !��V�=O�����=wJ������,>Xk!> :����>�N������􋆼h�U��^�%�>	�=ȴZ���=D�.�p;�<�S><�(�cX��p�i�H?���=d�齔��=�㽇:Y=������3�Kh�n�=�FV=P�d<��;|нh�}=��>��罯�X�����cݽ\2;�Z=+��=��<
��E&�$�ڽJf��HH= �9˃1�2�=m��H�F���&�Psx���C�>P�Z<� �lc	���>�`==S>x��<.�� .��H�����=�ښ���l�.��=X����6=NB�=ɩ>�X��Q���o=�)˽��\��+��,����>!�!>,�.j��  ��`�ý���L�N��ui><�k?�(�A�׾���+���e>q]=zː=����Z�>���=�/>�i��#�=ĉ�<�.�>V4=
k>��(=,����HN��0�=�p����=��'��<����>GC7>V�8�+��<>K����N>`T����+��5?>�����wL>x�� >6u�;`?����S��ט>��=�H>���<�q=��>Hv�>��:��i׺�t�>�}$�l�{���>N�O=��=���N����D+=P�b����-�; N�;�Q��H)�=���>�Yf>�_n=�G�>o���ؾ�@~��"�7�F��>f٩��b�����<.��X:��+�=]=(�|��<}��<��&=�������f=��=H��<kR��[>������=jٹ=X�=�er�|����{�%���L������(�ӥ=�1]��p��)�p��=>�<�[=|��PF>ף�;#�D�M����Z���,��?v~�>������=�tǾ-F?&)��Ee��*��V"���XY>���",��F��}2��@?D�žA0�����7�>�IݿR�*�Rל�z^�>�G
?1�w>$5M?%V?೜��2�>�|��y��2��v��<��ƽvy�>���>�;L��~��{��B�>��!>kx�88A=�:>���[����>$��=5k&�u �>��E>j����@>V�9>��[��
�T^�) �q>>M�ju!�$}�>A�>Mq{>g8x>�뎾_Pt�VJ��x�:?՚>�}�_N�M߻>�>f���>�d��|ؽ�Y�<���=NU�Z�	�N�ڼ�=ļ���^�=!N<T������<�L=�[콪}u<<���9h��MTc�A�=���!��=�.�j:�-��Ur=0�F�$�X=���D�ӽ�/۽x��S��uTq=L[J�L�R<��=$�����ؗT=;� ��<S3*=��K�)�=��e�mc�;BO�=��r=Z5�=h�t7�=�ǽPp6�oW�jkl��oJ=�����������	B_�N"����
�5��{��F�=|�s='�b��؋�=�z>����g�&���U�������G&��w�c�yb?.䫿*��:j�˿�[�=O��/��3*��R��hއ�j& �u1���cо�3���<�3ž.�B�T{���)�M�VW5=���?턇��>���<1m">���mĈ���ɾ2�޾�@��>������M?���>n �X�>�C�=��Q� bq=2q>uܞ�\v-������M�1��;�;������by�຾�ɽ$�Ҽ6U2��.E�ک��fA����G+>��Ⱦ�K����%?��J�5\������N�y���&���
����4���,���a>|T{=�ۋ>3�;>��[��'��C���xA=f�ٽl&&����=8��<�Ћ�⭸;jI���B =����lݽů!�T�ɽD���0�/��ѧ�߬;�xG�<����Q,>\7=r]�d8��)�����ٽVm�����)�<�.��E˓<�N>�>Y ���K<)�=�JN�$䳾~�{�I���ǖc�o"��V�=l｠���P-���
>�(ѽ�$�=@B��@���ݕ�H㼨(�=��=B]S�EU�۹��i���m� >��� \�;��]��8�� C�<am��� ��'	�̭0=轠ļ��L�������=�m��r��nٽ '�<|�۽��=����t ��D|��Tܽ��O����0�Z1��Kۓ<�`D<I���Π�=1\��aC�(������n�
�Qw�|ࣼD5����f׾=$T2�����V�<�+_��
a;���������u��<F� �a^��,�Ju��Yz��m�%mN=m򕽜i#���4��T�=�8��q`�(�Ͻ9��> �o=�+�h���R�>J1�=��o%��X�޽bP޽�Y��}��9�U>��̿���=eCɽݞ>m�R%c?g0U=x��>Tf`���f�����̿Ds�hf&���=>�V?=E>x��>5�>%=ȝ��@�潁a>>[�=���?I�׿�~�<�@���w��'V����/�^�qL>S}�$�l��"�>�;?�����>�:>�h�?����o��mܾ���N�Z?�
 >9־�:�<Ӥ��m��<�f�>#�'�Qf����'��Պ>}��>��-����>��h���>?>����ݼ<�V=]5�<��ν��\>��0��<2Qe��>�X>U��<wé����0��4�����:���������y��\ҽx����5���)������6 ��x˽��?���ؽ`h��/����=��ӽ�"�����K��m�ɽ�ʳ���%<4�+����>��!��`M��i�(;b<<ʌ>������(�Dg=��Ľd&�����=�@�=Gނ=����"e�=�e����> yż�E��4^��tAo=�P����L<I�H��'�=���>�b>��;>���=5p'<U�>�P㾬X��>��[�� ����>�r�=7�b��L��鲔��n���zn=ց�<Ai��|ﺾАн�JU�$5���%�mr��Ԯ����,澑_��1<�Tï��H���  ?�K��$�D�$����5��o`�Ο	��房�¾�+�C�o�=>r��=)��*�z�����<�=E�%?��6�Y���\��m��3��<(e�����܁�=�E��L��b5��{��i%վ˨���w�>���䈁��%������\�t?��޿j	m��ͼ��٬�r}=��f=��D�	����6���m�?���>����<5��(��H\�+�	����M�K>b��=�-C<	A=G&$=�h��O<tM:;��>��6޾�=[�<_�]=E*�O�$���D�L��ݑ��
��<jـ=gI������`�=���<�.���m��x��X�p�28>��>&�Xc>�*A����(�{=�6d���w�L�,= �c<���=`a��d����=&����SO���<�R;��==�=j�����˼<6彨抽JZ��������=�NM=�xI<�gA=SG�=b
½�;�=9�����M��=�<ϼ�/ڽy�*���L�a�f���<i�����M��y��<�e�<�M�Jν��S����:>�]=�
�=�/�=��>
�H>#=��=`�ݽ\tJ�I����뼍=�>���U���9�b>��=�.=	x��ཛ�YY	<2!��H�:�&_�OE=�`�FϚ����=V�=�*3<b-w>s�"��p�bx8��h@=9�۫=�������G�<}�N���'��9n=�R=�꽴4༷2S>�b/;��<��S(>��>���1�����="N��ջ��n���aP�0��6�=�=do�>�|�籾=o >'M��d�_���[����>e����͔<ߏv��ѓ�&.>���"��D�>�O½�
��.�d>�(ĽV�b�)Ӿ��\Ž����/>UB@�аý���[څ�l:�����4q�1��=���!4�G�M�3�=�~̽enҽ=�7=��>��=�lc�=��<�Ͽ� ���}�� >�?��U>�'>c�?5^7�.�����V��>3�	�Uj��X�>F6<���<Ճ��=�J>p��=	��0�ɽx�Ľ���=hN(��=�=�����I=&��<��>>�Sz<�����w���=�X���=���s�����(�g��=nn�<Y�<j��D�=?��s
!��3ּoH><��=~�^>�C�<s��?0f��4d��X��<�	�4�����>d!	���t�p߂����Ѫ��L�����������*5�7�?��ྮ2O�$;��wW���h?#`&�f�ڿ�v �1��D���0>ʫ2������E=P[������ ?B�>�㿚��OYe��i�+���cUV� �׽MGq��b>2���d��i
� �<A��F��= ������0� =jDL� �<�� ��b����=Tz=.+�=~��O�r=|�=s�4�h�n��.��T{��5V��o\��7�=w�����ཝEӽ�iQ�ڋ�<��*튾��>�V�s�=�˽�<��O˽ �˼�r��PE����f�L�	��� wн)�@�;����B ��� ]��a �:�n�Vn� ��pE̽�
������c����_���:�h��hg=�W����} d�͗���������~.��C�xܻ����7ƽ�ܙ�q�=��%��5��67���� p=R����ܽG��=V�H=,��<���:�(��#��0�d<�WK���=C��<��
��k��함�.|׽�H�<�I�=)� m�Ӣ����~��<�:����=z��_G�tUB�a}���9�=���������=���<
���Ѿ�;�>}���ҔK>,�U>C�ž�BZ��(�<�|��Dv��I�P>��=,��>�.r>?������^��U�B>{��G�T>)����
�eJ?���>� ?:|�>���xf���*?<A3>!�?[.>�ė�WV�hN�=[f^<��>�9E>(       3�ſ߄F��#��� �35$�L >�v��s�?�<�n;�� ��`��f٥��56=Hlx?6����;r����-�</�>��V���M�'����m ?�t���_=ዒ������z{=U�P�/�6��)�':D>'�p?<�/��>8q��#�但�̽�ms�(       ��?�?�򕿣7�<�����>+F�>�@��==.�=H��;�>��?����<zA�t%�>���=��=��?��1��;�<��>�s��޾Ml��!��A>
���-?hͼ8p>��<3��;~�1�?�=BTn?^�=���<`2v<��>       v���(       ���)&����=�b7�����Ի��R>�<��$�M�Ծw���5 ?�5��+�q�/?j��*����Y�
C��Ź:?�L�w}�����n'�⭽����ڃ�����h�������;?:��>K꼽3�K?0��=��۽r�
�^%�&��>�/?(       X� �a�}>�*�>�+��(���jt���N��bd>gi��gb�^x�S�濭a���L��b
���d���F�=�9����Ŀ�B��:���?	�ȿ�5�;BJ��j�0���b��o>�c�>��'�b�=M��<�Ȫ�`� ?k��>�ox�vx�>���To+�